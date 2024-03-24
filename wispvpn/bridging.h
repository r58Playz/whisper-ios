#include <stdbool.h>

bool whisper_init(int fd, char *ws, unsigned short mtu);
bool whisper_start();
bool whisper_stop();

char *whisper_get_ws_ip();
void whisper_free(char *s);

