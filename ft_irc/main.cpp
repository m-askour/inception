#include "server/server.hpp"


int main(int ac, char **av)
{
    if (ac != 3)
    {
        std::cout << "error input, put it like this ./ircserv <port> <password>" <<std::endl;
        return 1;
    }
    int port = atoi(av[1]);
    if (port <= 0 || port > 65535)
    {
        std::cout << "Invalid port range\n";
        return 1;
    }
    server server(AF_INET, SOCK_STREAM, 0);
    try
    {
        server.start_server(port, std::string(av[2]));

    }
    catch(std::exception &e)
    {
        std::cout << e.what() << std::endl;
    }
}