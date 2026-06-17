#include "client.hpp"

client::client()
    : client_fd(-1),
      is_authenticated(false),
      is_connected(false),
      is_registered(false),
      is_operator(false)
{}

client::client(int fd)
    : client_fd(fd),
      is_authenticated(false),
      is_connected(false),
      is_registered(false),
      is_operator(false)
{}
client::~client()
{
}

// configuration
void client::set_password(const std::string &pwd)
{
    password = pwd;
}
void client::set_username(const std::string &user)
{
    username = user;
}
void client::set_nickname(const std::string &nick)
{
    nickname = nick;
}
void client::set_realname(const std::string &reln)
{
    realname = reln;
}

// // status checks
bool client::is_authenticated_client() const
{
    return is_authenticated;
}
bool client::is_connected_client() const
{
    return is_connected;
}
bool client::is_registered_client() const
{
    return is_registered;
}
bool client::is_nickname_set_client() const
{
    //this chekc it whene connect it to the client 
    return !nickname.empty();
}
bool client::is_username_set_client() const
{
    //this chekc it whene connect it to the client 
    return !username.empty();
}

bool client::is_password_set_client() const
{
    //this chekc it whene connect it to the client 
    return !password.empty();
}

// // getters
// const std::string &get_server_ip() const;
// int get_server_port() const;
int client::get_fd()const
{
    return client_fd;
}
const std::string &client::get_username() const
{
    return this->username;
}

const std::string &client::get_nickname() const
{
    return this-> nickname;
}
const std::string &client::get_password() const
{
    return password;
}
const std::string &client::get_buffer() const
{
    return input_buff;
}

// // operations
ssize_t client::send_data(const std::string &data)
{
    return send(client_fd, data.c_str(), data.size(), 0);
}
ssize_t client::receive_data()
{
    char buffer[1024];
    ssize_t bytes_received = recv(client_fd, buffer, sizeof(buffer) - 1, 0);
    if (bytes_received > 0)
    {
        buffer[bytes_received] = '\0';
        input_buff += buffer;
    }
    return bytes_received;
}
std::string client::extractLine()
{
    size_t pos = input_buff.find('\n');
    if (pos == std::string::npos)
        return "";
    std::string line = input_buff.substr(0, pos);
    input_buff.erase(0, pos + 1);
    // strip trailing \r if present
    if (!line.empty() && line.back() == '\r')
        line.pop_back();
    return line;
}
bool client::hasCompleteLine()
{
    return input_buff.find("\n")!= std::string::npos;
}
bool client::check_client_info() const
{
    return !username.empty() && !nickname.empty() && !password.empty();
}
void client::print_client_info() const
{
    std::cout << "Client Info:\n";
    std::cout << "Username: " << username << "\n";
    std::cout << "Nickname: " << nickname << "\n";
    std::cout << "Password: " << password << "\n";
}