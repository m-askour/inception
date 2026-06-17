#include "bot.hpp"
bot::bot(): input(""), response("")
{

}
bot::bot(const bot &other): input(other.input), response(other.response)
{

}
bot &bot::operator=(const bot &other)
{
    if (this != &other)
    {
        this->input = other.input;
        this->response = other.response;
    }
    return *this;
}
bot::~bot()
{}
bool bot::connectToServer(std::string ip, int port, std::string password)
{
    this->server_ip = ip;
    this->server_port = port;
    this->server_password = password;
    
    // Create socket
    socketfd = socket(AF_INET, SOCK_STREAM, 0);
    if (socketfd < 0)
    {
        std::cout << "Error creating socket" << std::endl;
        return false;
    }
    
    // Set server address
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    server_addr.sin_addr.s_addr = inet_addr(ip.c_str());
    
    // Connect to server
    if (connect(socketfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
    {
        std::cout << "Error connecting to server" << std::endl;
        return false;
    }
    
    std::cout << "Connected to server at " << ip << ":" << port << std::endl;
    
    // Send password
    char buff[1024];
    memset(buff, 0, 1024);
    
    // Receive password prompt
    recv(socketfd, buff, 1024, 0);
    std::cout << buff << std::endl;
    
    // Send password
    send(socketfd, password.c_str(), password.length(), 0);
    
    return true;
}
void bot::communicateWithServer()
{
    char buff[1024];
    std::string userInput;
    
    while (true)
    {
        std::cout << "You: ";
        std::getline(std::cin, userInput);
        
        if (userInput == "exit")
        {
            std::cout << "Disconnecting..." << std::endl;
            break;
        }
        
        // Process input through bot logic
        std::string botResponse = processinput(userInput);
        
        // Send to server
        send(socketfd, botResponse.c_str(), botResponse.length(), 0);
        std::cout << "Bot: " << botResponse << std::endl;
        
        // Receive response from server
        memset(buff, 0, 1024);
        int recvd = recv(socketfd, buff, 1024, 0);
        if (recvd > 0)
        {
            std::cout << "Server: " << std::string(buff, recvd) << std::endl;
        }
    }
    
    close(socketfd);
}
void bot::GetUserInput()
{
    std::string input;
    while (true)
    {
        std::getline(std::cin, input);//this to read the 
        //when there is input it weell be processing first 
        std::cout <<  processinput(input) << std::endl;        
    }
}
std::string  bot::processinput(std::string &input)
{

        history.push_back(input);
        //check what in thhis input
        std::string response;
        if (keywordMatching(input, response))
            return response;
        return failbackResponse();
   
    //generate the response 
}



std::string calculate(std::string input) {
    int pos_op = -1;
    char op;
    
    // Find the operator position
    for (size_t i = 0; i < input.size(); i++) {
        if (input[i] == '+' || input[i] == '-' || 
            input[i] == '*' || input[i] == '/') {
            pos_op = i;
            op = input[i];
            break;
        }
    }
    
    if (pos_op == -1) return "Invalid format";
    
    int num1 = std::stoi(input.substr(0, pos_op));
    int num2 = std::stoi(input.substr(pos_op + 1));
    int result = 0;
    
    switch (op) {
        case '+': result = num1 + num2; break;
        case '-': result = num1 - num2; break;
        case '*': result = num1 * num2; break;
        case '/': if (num2 != 0) {
                result = num1 / num2;
            } else {
                std::cout << "Error: Division by zero!" << std::endl;
                result = 0;
            }
            break;
        default: return "Error";
    }
    
    char c = result + '0';
    std::string s(1,c);
    return (s);
}
bool bot::keywordMatching(std::string &input, std::string &response)
{

    if (input.find('?') != std::string::npos)
    {
        response = "Oh, good question… 🤔mmmmm… I don’t know the answer";
        return true;
    }
    // hello and hi and hey
else if (input.find("HI") != std::string::npos || 
         input.find("Hi") != std::string::npos || 
         input.find("hi") != std::string::npos || 
         input.find("Hello") != std::string::npos ||
         input.find("hello") != std::string::npos ||
         input.find("hey") != std::string::npos)
{
    response = "Hi";
    return true;
}  
    else if (input.find("help") != std::string::npos)
    {
        response = "Hi I'm chat bot i can i can unser ur quastion or talck smal conversation";
        return true;
    }
    else if (input.find("What's my name") != std::string::npos)
    {
        if (!userName.empty())
        {
            response = "Your name is " + userName;
        }
        else
        {
            response = "What's your name? Tell me!";
        }
        return true;
    }
    else if (input.find("My name is") != std::string::npos)
    {
        size_t pos = input.find("My name is") + 10;
        userName = input.substr(pos);
        response = "Nice to meet you, " + userName + "!";
        return true;
    }
    else if (input.find("+") != std::string::npos || input.find("-") != std::string::npos || input.find("/") != std::string::npos || input.find("*") != std::string::npos)
    {
        response = calculate(input);
        return true;
    } 
    else
    {
        response = "I’m not \
        Google or ChatGPT…  \
        I actually think before answering 😏";
        return true;
    }
    return false;
}
std::string bot::failbackResponse()
{
    //this is the output responce what the boot say and whatv the bot do
    return "I don't understand what do u main ";
}