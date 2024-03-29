#include <stdbool.h>

bool whisper_init_logging(const char *app_name);
bool whisper_init(int fd, const char *ws, unsigned short mtu);
bool whisper_start();
bool whisper_stop();

char *whisper_get_ws_ip();
void whisper_free(char *s);

