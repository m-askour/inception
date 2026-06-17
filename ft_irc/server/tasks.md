## 1. Fix poll properly (first priority)
use revents
handle POLLIN
remove disconnected clients properly
##  2. Remove waiting_client_responce
don’t mix blocking accept loop with poll
## 3. Make clean structure:
accept_new_client()
handle_client(i)
remove_client(i)
## 4. Add client array tracking
store usernames
store state (authenticated / not)