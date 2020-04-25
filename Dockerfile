FROM    nginx:stable-alpine
RUN     apk update                                      \
        && for x in                                     \
        $(                                              \
                for y in 0 1 2 3 4 5 6 7 8 9; do        \
                        apk list                        \
                        | awk /nginx/'{ print $1 }'     \
                        | awk -F-$y  '{ print $1 }'     \
                        | grep -v '\-[0-9]';            \
                done                                    \
                | sort                                  \
                | uniq                                  \
                | grep -v ^nginx$                       \
        ); do                                           \
                apk del $x;                             \
        done                                            \
        && apk upgrade nginx
RUN     rm -rf /etc/nginx/conf.d                        \
        && ln -s /run/secrets/etc/nginx/conf.d /etc/nginx
