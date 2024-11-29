typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet


# Путь к установке oh-my-zsh
ZSH=/usr/share/oh-my-zsh/

# Путь к теме powerlevel10k
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme


#ZSH_THEME="robbyrussell"

#source /usr/share/zsh-theme-robbyrussell.zsh-theme

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Список используемых плагинов
plugins=( git sudo zsh-256color zsh-autosuggestions zsh-syntax-highlighting )
source $ZSH/oh-my-zsh.sh

# Функция для обработки не найденных команд
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} может быть найден в следующих пакетах:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]] ; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# Определение обертки AUR
if pacman -Qi yay &>/dev/null ; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null ; then
   aurhelper="paru"
fi

# Функция для установки пакетов из официального репозитория и AUR
function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null ; then
            arch+=("${pkg}")
        else 
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}

# Алиасы
alias t='touch' # Создание файла
alias c='clear' # Очистка терминала
alias l='eza -lh --icons=auto' # Длинный список
alias ls='eza -1 --icons=auto' # Короткий список
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # Длинный список все
alias ld='eza -lhD --icons=auto' # Длинный список каталогов
alias lt='eza --icons=auto --tree' # Список папок как дерево
alias un='$aurhelper -Rns' # Удалить пакет
alias up='$aurhelper -Syu' # Обновить систему/пакет/aur
alias pl='$aurhelper -Qs' # Список установленных пакетов
alias pa='$aurhelper -Ss' # Список доступных пакетов
alias pc='$aurhelper -Sc' # Удалить неиспользуемый кэш
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # Удалить неиспользуемые пакеты
alias vc='code' # GUI редактор кода
alias ob='obsidian' # obsidian
alias chx='chmod +x ' # Изменение прав
alias ac='cd && cd .scripts/action && sudo python3 action.py'
alias vulmap='python3 ~/.scripts/vulmap.py'
alias ztcg='sudo zerotier-cli join ebe7fbd445533037' 
alias ztp='sudo zerotier-cli join 41d49af6c2e82a63'
alias ztsh='sudo zerotier-cli join b15644912ef73fd5'
alias zti='sudo zerotier-cli info'
alias gt='git clone'
alias olse='sudo systemctl stop ollama.service && ollama serve'

alias bettercap='cd ~/Programs/bettercap && s go run main.go -eval "ui on"'
alias game='cd ~/Games'


alias themes='cd /home/doshlk/.config/hyde/themes/'

alias sn='syncthing'


alias weather='~/.scripts/weather.sh'
alias wr='~/.scripts/weather.sh Coevorden | lolcat'


alias pd='pushd'
alias pod='popd'


alias b='btop'
alias p='~/.scripts/pomo.sh'

alias down='cd ~/Downloads'

alias akill='~/.scripts/akill.sh'


alias waydefwaydef='cd ~/.config/waybar/old_style_hyde/ && s ./set.sh'
alias waywin='cd ~/.config/waybar/win10-style-waybar/ && s ./set.sh'


alias wi='waydroid app install'


# yay 
alias yr='yay -Rns' # 
alias ys='yay -S' # 
alias yss='yay -Ss' # 
# Мои Алиасы
alias nf='cd && clear && neofetch --os_arch off --cpu_cores logical --memory_percent off --refresh_rate off' # Вывод информации о системе
alias nfb='cd && clear && neofetch --os_arch off --cpu_cores logical --memory_percent off --refresh_rate off --ascii_distro BlackArch' # Neofetch для BlackArch
alias nfr='cd && clear && neofetch --os_arch off --cpu_cores logical --memory_percent off --refresh_rate off --ascii_distro redhat' # Neofetch для redhat
alias nfwin='cd && clear && neofetch --os_arch off --cpu_cores logical --memory_percent off --refresh_rate off --ascii_distro Windows10' # Neofetch для Windows10
alias nfs='cd && clear && neofetch --os_arch off --cpu_cores logical --memory_percent off --refresh_rate off --ascii_distro SereneLinux' # Neofetch для SereneLinux
alias ff='cd && clear && fastfetch' # Fastfetch
alias ca='cd && clear && cava' # Cava
alias zc='cd && ed .zshrc && source .zshrc' # Редактировать .zshrc
alias srn='sudo reboot now' # Перезагрузка системы
alias cpumax='sudo cpupower frequency-set -g performance' # Максимальная производительность CPU
alias cpulow='sudo cpupower frequency-set -g powersave' # Минимальное энергопотребление CPU
alias mpf='makepkg --config ~/.makepkg-clang.conf -sric --skippgpcheck --skipchecksums' # Создать пакет с использованием clang
alias wifi='nmtui' # Настройка Wi-Fi



alias bdir='~/.scripts/backup_dir.sh'
alias clock='tty-clock -s -c -C 1'
alias asciiwebcam='python ~/.scripts/webcam_ascii.py'
alias menu='./.scripts/menu.sh'
alias ed='micro'
alias sed='sudo micro'
alias stabledif=' cd ~/Programs/stable-diffusion-webui && python3.10 webui.py --allow-code --skip-torch-cuda-test --skip-python-version-check --no-progressbar-hiding --xformers --no-half-vae --api --api-auth idk:cdf'
alias mystablebedif='  cd ~/Programs/stable-diffusion-webui && python3.10 my_webui.py --allow-code --skip-torch-cuda-test --skip-python-version-check --no-progressbar-hiding --xformers --no-half-vae --api --api-auth idk:cdf'
alias paket='pacseek'
alias mamunt='sudo mount --bind /run/media/doshlk/d770daa7-8b59-45d6-91d2-5d13fe540186/server ~/server && sudo mount --bind /run/media/doshlk/d770daa7-8b59-45d6-91d2-5d13fe540186/myprojects ~/myprojects'
alias mamuntp='sudo mount --bind /run/media/doshlk/d770daa7-8b59-45d6-91d2-5d13fe540186/Programs ~/Programs'
alias im='kitten icat'
alias etp='sudo -E ettercap -G'

alias minecraft_server='java -Xmx14G -Xms2G -jar ~/pizda_server/server.jar nogui'



alias tablica='./.scripts/type_csv.sh'


alias untar='sudo tar -xzvf'
alias s='sudo'


# Дополнительные алиасы для работы с каталогами
alias ..='cd ..' # Перейти на уровень выше
alias ...='cd ../..' # Перейти на два уровня выше
alias .3='cd ../../..' # Перейти на три уровня выше
alias .4='cd ../../../..' # Перейти на четыре уровня выше
alias .5='cd ../../../../..' # Перейти на пять уровней выше
alias /='cd /' # Перейти в корневой каталог

# Алиасы для работы с файлами
alias du='du -sh' # Показать размер каталога
alias df='df -h' # Показать информацию о файловой системе
alias rm='rm -i' # Запрашивать подтверждение перед удалением
alias cp='cp -i' # Запрашивать подтверждение перед перезаписью файлов
alias mv='mv -i' # Запрашивать подтверждение перед перезаписью файлов

# Алиасы для работы с git
alias gs='git status' # Показать статус репозитория
alias gl='git log --oneline' # Показать лог коммитов в одном ряду
alias ga='git add' # Добавить файлы в индекс
alias gc='git commit -m' # Закоммитить изменения с сообщением
alias gp='git push' # Отправить изменения в удаленный репозиторий
alias gd='git diff' # Показать различия между версиями
alias gco='git checkout' # Переключиться на другую ветку
alias gb='git branch' # Показать ветки
alias gpl='git pull' # Получить обновления из удаленного репозитория
alias gr='git rebase' # Выполнить rebase

alias browser-cli='browsh'




# Алиасы для поиска файлов и директорий
alias f='find . -name' # Поиск файлов по имени
alias ff='find . -type f -name' # Поиск файлов по имени
alias fg='find . -type d -name' # Поиск директорий по имени
alias grep='grep --color=auto' # Показать результаты поиска с цветом

# Алиасы для отображения открытых портов
alias ports='netstat -tulanp | grep -E "^Proto|^tcp|^udp" | sort -k 4'

# Функция для добавления нового алиаса
add_alias() {
    local alias_name="$1"
    local description="$2"
    local command="$3"

    if [[ -z "$alias_name" || -z "$description" || -z "$command" ]]; then
        echo "Usage: add_alias <alias_name> <description> <command>"
        return 1
    fi

    # Добавление алиаса в файл
    echo "${alias_name}|${description}|${command}" >> ~/.aliases

    # Обновление алиаса в текущей сессии
    alias "$alias_name"="$command"
    
    echo "Alias '$alias_name' added."
}

# Функция для отображения таблицы алиасов
show_aliases() {
    local col_alias=15
    local col_desc=40

    # Заголовок таблицы
    printf "%-${col_alias}s | %-${col_desc}s | %s\n" "Алиас" "Описание" "Команда"
    printf "%${col_alias}s-+-%${col_desc}s-+-%s\n" "" "" ""

    # Чтение алиасов из файла и отображение
    while IFS='|' read -r alias_name description command; do
        printf "%-${col_alias}s | %-${col_desc}s | %s\n" "$alias_name" "$description" "$command"
    done < ~/.aliases
}

# Проверка наличия файла с алиасами и создание его при необходимости
if [[ ! -f ~/.aliases ]]; then
    touch ~/.aliases
fi

# Настройка темы powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh





fpath=(/opt/brew/share/zsh/site-functions $fpath)








export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export PATH=$PATH:/home/doshlk/.local/bin
: undercover && export PS1='C:${PWD//\//\\}> '
: undercover && new_line_before_prompt=no
: undercover && export PS1='C:${PWD//\//\\}> '
: undercover && new_line_before_prompt=no
: undercover && export PS1='C:${PWD//\//\\}> '
: undercover && new_line_before_prompt=no


