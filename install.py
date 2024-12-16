from collections.abc import Callable
import argparse
from datetime import datetime
import glob
import os
import pwd
import shutil
import socket
import subprocess

try:
    import git

    has_git_support: bool = True
except ImportError:
    has_git_support: bool = False

INSTALL_TIME = datetime.now()


def abort(message: str, exit_code: int = 1):
    print(message)
    exit(exit_code)


def warning(message: str):
    print(message)


def get_config_git_version() -> str:
    if not has_git_support or not git:
        return "?"

    repo = git.Repo(get_config_path())
    return repo.head.commit.hexsha


def get_user_info(allow_root: bool) -> pwd.struct_passwd:
    uid: int = os.getuid()
    if not allow_root and uid == 0:
        abort("Script can only be run as user 'root' with the '--allow-root' flag")
    return pwd.getpwuid(uid)


def get_user_home() -> str:
    return get_user_info(True).pw_dir


_hostname: str | None = None


def get_hostname() -> str:
    if _hostname:
        return _hostname
    return socket.gethostname()


def guess_os() -> str:
    hostname: str = get_hostname()
    if "debian" in hostname:
        return "debian"
    return "arch"


DEFAULT_CONFIG_PATH = "/home/me/sync/config"
_config_path: str | None = None


def get_config_path() -> str:
    if _config_path:
        return _config_path
    return os.path.abspath(os.path.dirname(__file__))


def perform_package_installation(
    packages: list[str],
    no_confirm: bool = False,
    program: str = "pacman",
    run_sudo: bool = True,
):
    if program in ["apt", "apt-get"]:
        args: list[str] = ["install"]
        if no_confirm:
            args.append("-y")
    else:
        args: list[str] = ["-Sy", "--needed"]
        if no_confirm:
            args.append("--noconfirm")

    command: list[str] = [program]
    if run_sudo:
        command.insert(0, "sudo")

    subprocess.run(command + args + packages)


def get_installed_packages(q_args: list[str] = []) -> list[str]:
    package_manager: str = "pacman"
    if not shutil.which(package_manager):
        warning(f"System does not have package manager '{package_manager}'")
        return []
    installed_packages = []
    for line in subprocess.check_output([package_manager, "-Q"] + q_args).splitlines():
        installed_packages.append(str(line, "UTF-8").split(" ", 1)[0])
    return installed_packages


def get_packages_diff() -> dict[str, list[str]]:
    installed_packages = get_installed_packages()
    all_diffs: dict[str, list[str]] = {}

    for category, packages in get_packages("arch").items():
        diff = [item for item in packages if item not in installed_packages]
        all_diffs[category] = diff
    return all_diffs


def get_additionally_installed_packages():
    installed_packages = get_installed_packages(["-t", "-t"])

    all_packages = [item for p in get_packages("arch").values() for item in p]

    manual_installed = []
    for x in installed_packages:
        if x not in all_packages:
            manual_installed.append(x)
    return manual_installed


def get_packages_files(os_dist: str) -> list[str]:
    packages_path = get_config_path() + f"/packages/{os_dist}"

    packages_files: list[str] = [
        f"{packages_path}/{package_file}" for package_file in os.listdir(packages_path)
    ]

    return packages_files


def get_packages(os_dist: str) -> dict[str, list[str]]:
    packages_files: list[str] = get_packages_files(os_dist)

    packages: dict[str, list[str]] = {}
    for file_name in packages_files:
        if not os.path.exists(file_name):
            continue
        try:
            file_packages: list[str] = []
            with open(file_name, "r") as f:
                for line in f:
                    comment_pos = line.find("#")
                    line_end = len(line) if (comment_pos < 0) else comment_pos
                    file_packages.extend(line[:line_end].split())

            category: str = os.path.basename(file_name)
            packages[category] = file_packages
        except OSError:
            warning(f"Unable to read packages file '{file_name}'")
    return packages


CONFIG_TYPES: list[str] = [
    "",
    "home",
    ".config",
]


class Config:
    def __init__(
        self,
        source: str,
        destination: str,
        is_directory: bool = False,
        make_destination: bool = False,
        config_type: str = CONFIG_TYPES[0],
    ):
        self.source: str = source
        self.destination: str = destination
        self.is_directory: bool = is_directory
        self.make_destination: bool = make_destination
        self.config_type: str = config_type


config_files: list[Config] = [
    Config(
        "{config_source}/.bash_profile",
        "{home_config_destination}/.bash_profile",
        config_type="home",
    ),
    Config(
        "{config_source}/.bashrc",
        "{home_config_destination}/.bashrc",
        config_type="home",
    ),
    Config(
        "{config_source}/.zshrc", "{home_config_destination}/.zshrc", config_type="home"
    ),
    Config(
        "{config_source}/.zshenv",
        "{home_config_destination}/.zshenv",
        config_type="home",
    ),
    Config(
        "{config_source}/.zprofile",
        "{home_config_destination}/.zprofile",
        config_type="home",
    ),
    Config(
        "{config_source}/.gitconfig",
        "{home_config_destination}/.gitconfig",
        config_type="home",
    ),
    Config(
        "{config_source}/.tmux.conf",
        "{home_config_destination}/.tmux.conf",
        config_type="home",
    ),
    Config(
        "{config_source}/.nanorc",
        "{home_config_destination}/.nanorc",
        config_type="home",
    ),
    Config(
        "{config_source}/.clang-format",
        "{home_config_destination}/.clang-format",
        config_type="home",
    ),
    Config(
        "{config_source}/.clang-tidy",
        "{home_config_destination}/.clang-tidy",
        config_type="home",
    ),
    Config(
        "{config_source}/gnupg/gpg-agent.conf",
        "{home_config_destination}/.gnupg/gpg-agent.conf",
        make_destination=True,
        config_type="home",
    ),
    Config(
        "{config_source}/gnupg/gpg.conf",
        "{home_config_destination}/.gnupg/gpg.conf",
        config_type="home",
    ),
    Config(
        "{config_source}/ssh/config",
        "{home_config_destination}/.ssh/config",
        make_destination=True,
        config_type="home",
    ),
    Config(
        "{config_source}/sway/{hostname}.conf",
        "{config_destination}/sway/config",
        make_destination=True,
        config_type=".config",
    ),
    Config(
        "{config_source}/mako/{hostname}.conf",
        "{config_destination}/mako/config",
        make_destination=True,
        config_type=".config",
    ),
    Config(
        "{config_source}/waybar",
        "{config_destination}/waybar",
        is_directory=True,
        config_type=".config",
    ),
    Config(
        "{config_source}/wofi",
        "{config_destination}/wofi",
        is_directory=True,
        config_type=".config",
    ),
    Config(
        "{config_source}/alacritty",
        "{config_destination}/alacritty",
        is_directory=True,
        config_type=".config",
    ),
    Config(
        "{config_source}/nvim",
        "{config_destination}/nvim",
        is_directory=True,
        config_type=".config",
    ),
    Config(
        "{config_source}/ranger",
        "{config_destination}/ranger",
        is_directory=True,
        config_type=".config",
    ),
    Config(
        "{config_source}/code/settings.json",
        "{config_destination}/Code - OSS/User/settings.json",
        make_destination=True,
        config_type=".config",
    ),
]


def fix_path_in_configs():
    def run_replace_command(pattern):
        command = ["find", ".", "-type", "f", "-exec", "sed", "-i", pattern, "{}", "+"]
        subprocess.run(command, cwd=get_config_path())

    config_path = get_config_path()

    escaped_default_path: str = DEFAULT_CONFIG_PATH.replace("/", "\\/")
    escaped_path = config_path.replace("/", "\\/")

    run_replace_command(f"s/{escaped_default_path}/{escaped_path}/")


def install_configs(config_filter: Callable[[Config], bool] = lambda _: True):
    def expand_config_path(path: str) -> str:
        user_home: str = get_user_home()
        config_dir: str = get_config_path()
        hostname: str = get_hostname()
        return path.format(
            config_source=f"{config_dir}",
            config_destination=f"{user_home}/.config",
            home_config_destination=f"{user_home}",
            hostname=f"{hostname}",
        )

    for config in config_files:
        if not config_filter(config):
            continue

        source = expand_config_path(config.source)
        destination = expand_config_path(config.destination)

        destination_parent_dir: str = os.path.dirname(destination)
        if config.make_destination:
            os.makedirs(destination_parent_dir, exist_ok=True)

        if os.path.exists(destination) or os.path.islink(destination):
            backup_path: str = f"/tmp/config-install_{INSTALL_TIME}/{destination}"
            print(f"Creating backup of '{destination}' in '{backup_path}'")
            os.makedirs(backup_path, exist_ok=True)
            shutil.move(
                destination,
                backup_path,
                copy_function=lambda s, d: shutil.copy(s, d, follow_symlinks=False),
            )

        os.symlink(
            source,
            destination,
            config.is_directory,
        )


def install_aur_helper(aur_helper: str, no_confirm: bool = False):
    git_url = f"https://aur.archlinux.org/{aur_helper}.git"
    repo_dir = f"/tmp/{aur_helper}"

    # install build dependencies
    perform_package_installation(
        ["fakeroot", "debugedit", "binutils", "make", "gcc"], no_confirm=no_confirm
    )

    git_clone(git_url, repo_dir)

    makepkg_installation(repo_dir, no_confirm)


def git_clone(git_url: str, repo_dir: str):
    if has_git_support and git:
        git.Repo.clone_from(git_url, repo_dir)
    else:
        subprocess.run(["git", "clone", git_url, repo_dir])


def makepkg_installation(package_dir: str, no_confirm: bool = False):
    makepkg_args = ["makepkg", "-s", "-i"]
    if no_confirm:
        makepkg_args.append("--noconfirm")

    subprocess.run(makepkg_args, cwd=package_dir)


def install_packages(
    os_dist: str,
    package_filter: Callable[[str], bool] = lambda _: True,
    no_confirm: bool = False,
    aur_helper: str | None = None,
):
    all_packages: dict[str, list[str]] = get_packages(os_dist)

    for category, packages in all_packages.items():
        if not package_filter(category):
            continue

        if category != "aur":
            if os_dist == "debian":
                program = "apt-get"
            else:
                program = "pacman"
            perform_package_installation(packages, no_confirm=no_confirm, program=program)
        elif aur_helper:
            perform_package_installation(
                packages, no_confirm=no_confirm, program=aur_helper
            )
        else:
            warning("No AUR helper available for installation of AUR packages!")


def install_custom_packages(no_confirm: bool = False):
    repo_dir = "/tmp/arch-packages/"

    git_clone("https://github.com/taminob/arch-packages", repo_dir)

    for package in os.listdir(repo_dir):
        package_dir = repo_dir + package
        if package.startswith(".") or not os.path.isdir(package_dir):
            continue

        print(f"Installing custom package in '{package_dir}'")
        makepkg_installation(package_dir, no_confirm)


def set_default_shell():
    subprocess.run(["sudo", "chsh", "-s", "/usr/bin/zsh"])


def create_user_directories():
    home: str = get_user_home()
    os.makedirs(f"{home}/sync", exist_ok=True)
    os.makedirs(f"{home}/software/tests", exist_ok=True)
    os.makedirs(f"{home}/downloads", exist_ok=True)
    os.makedirs(f"{home}/videos/screen_recordings", exist_ok=True)
    os.makedirs(f"{home}/pictures/screenshots", exist_ok=True)


def create_user_symlinks():
    home: str = get_user_home()
    if not os.path.exists(f"{home}/tests") and not os.path.islink(f"{home}/tests"):
        os.symlink(f"{home}/software/tests", f"{home}/tests")
    if not os.path.exists(f"{home}/arch") and not os.path.islink(f"{home}/arch"):
        os.symlink(f"{home}/sync/arch", f"{home}/arch")


def main():
    parser = argparse.ArgumentParser("config install")
    parser.add_argument("--noconfirm", action="store_true")
    parser.add_argument("--aur-helper", type=str, default="yay")
    parser.add_argument("--aur", action="store_true")
    parser.add_argument("--allow-root", action="store_true")
    parser.add_argument("--config-path", type=str)
    parser.add_argument("--fix-path", action="store_true")
    parser.add_argument("--hostname", type=str, default=get_hostname())
    parser.add_argument(
        "--os", type=str, choices=["arch", "debian"], default=guess_os()
    )
    parser.add_argument("--install-custom", action="store_true")
    parser.add_argument(
        "--packages",
        type=str,
        nargs="*",
        choices=list(get_packages("arch").keys()) + list(get_packages("debian").keys()),
        default=[],
    )
    parser.add_argument("--create-user-files", action="store_true")
    parser.add_argument(
        "--configs", type=str, nargs="*", choices=CONFIG_TYPES, default=[]
    )
    parser.add_argument("--set-shell", action="store_true")
    args = parser.parse_args()

    get_user_info(args.allow_root)  # aborts if root is not allowed

    global _config_path
    if _config_path and os.path.normpath(args.config_path) != os.path.normpath(
        get_config_path()
    ):
        warning(
            f"Given config path '{_config_path}' does not match actual path '{get_config_path()}'"
        )
    _config_path = args.config_path
    if _config_path and not os.path.exists(_config_path):
        abort(f"Given config path '{_config_path}' does not exist")
    global _hostname
    _hostname = args.hostname

    if args.fix_path:
        print("Fixing paths in configuration files...")
        fix_path_in_configs()

    print("Installing configuration files ", args.configs, "...")
    install_configs(lambda c: c.config_type in args.configs)

    if args.aur:
        print("Installing AUR helper...")
        install_aur_helper(args.aur_helper, no_confirm=args.noconfirm)

    if args.os == "arch":
        # for now, this is only supported for systems based on arch
        print("Not installed packages: ", get_packages_diff())
        print(
            "Additionally installed packages: ",
            get_additionally_installed_packages(),
        )

    print("Installing packages ", args.packages, "...")
    install_packages(
        args.os, package_filter=lambda c: c in args.packages, no_confirm=args.noconfirm
    )
    if args.install_custom:
        print("Installing custom packages...")
        install_custom_packages(args.noconfirm)

    if args.set_shell:
        print("Settings default shell...")
        set_default_shell()

    if args.create_user_files:
        print("Creating user directories and symlinks...")
        create_user_directories()
        create_user_symlinks()


if __name__ == "__main__":
    main()
