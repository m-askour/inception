#ifndef BOT_HPP
#define BOT_HPP
#include <iostream>
#include <sys/socket.h>
#include <string>
#include <algorithm>
#include <vector>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>
///  dont forget to inherit from the server to takck the name of server and the name of the client to know the name of each client 


class bot
{
private:

    std::string input;
    std::vector <std::string> history; 
    std::string response;
    std::string userName;


    //change this bot to be like a client
    int socketfd;
    struct sockaddr_in server_addr;
    std::string server_ip;
    int server_port;
    std::string server_password;

public:
    bot(/* args */);
    bot(const bot &other);
    bot &operator=(const bot &other);
    ~bot();

    bool connectToServer(std::string ip, int port, std::string password);
    
    // ✅ NEW: Send/Receive from server
    void communicateWithServer();


    void GetUserInput();
    std::string processinput(std::string &input);
    bool keywordMatching(std::string &input, std::string &response);
    std::string failbackResponse();
};


#endif