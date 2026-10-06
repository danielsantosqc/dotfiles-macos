# ALIAS PARA BAT
# previa instalación de bat (brew install bat)
alias cat='bat'

# Alias para ejecutar mi script de monitoreo de Docker
# alias dockermon='$DOTFILES_DIR/bin/dockermon.sh'



#mis alias Python
alias python='python3'
alias pip='pip3'

# mis alias (list)
alias l='ls -1'
alias la='ls -a'
alias ll='listar -l'
alias lla='listar -al'


#alias listar puertos -----(SOLO macOs)-----
alias ports="echo '---  TCP connections - (Listen & Established)  ----' ; sudo lsof -i TCP -P -n +c 0 | column -t"
alias ports-listen="echo '---- TCP listening ports ----' ; sudo lsof -iTCP -sTCP:LISTEN -P -n +c 0 | column -t"
alias ports-udp="echo '---  UDP connections ----' ; sudo lsof -i UDP -P -n +c 0 | column -t"
alias ports-all="sudo lsof -i -P -n +c 0 | column -t"
# alias puertos-tcp="sudo lsof -iTCP -sTCP:LISTEN -P -n" 

# Notificaciones
# I'll be doing another one for Linux, but this one will give you 
# a pop up notification and sound alert (using the built-in sounds for macOS)

# se requiere (brew install terminal-notifier) https://github.com/julienXX/terminal-notifier
# Requires https://github.com/caarlos0/timer to be installed

# Mac setup for pomo
alias work="timer -n 'Working 🧑🏻‍💻' 6s  && terminal-notifier -message 'Pomodoro'\
        -title 'Work Timer is up! Take a Break 😊'\
        -sound Crystal"
        
alias rest="timer 10m && terminal-notifier -message 'Pomodoro'\
        -title 'Break is over! Get back to work 😬'\
        -sound Crystal"

