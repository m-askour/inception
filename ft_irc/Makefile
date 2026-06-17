c++ = g++
c++flags = -Wall -Werror -Wextra -std=c++98
name = ft_irc
files = main.cpp ./server/server.cpp

all: $(name)
$(name):
	$(c++) $(c++flags) $(files) -o $(name)
%.o: %.cpp
	$(c++) $(c++flags) -c $< -o $@
clean:
	rm -f $(name)
fclean: clean
re: fclean all