#include "moonbit.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

struct moonbit_string *moonbit_make_string(int32_t, uint16_t);

// Utils
void *moonbit_str_to_c_str(struct moonbit_string *ms) {
  int32_t len = Moonbit_array_length(ms);
  char *ptr = (char *)malloc(len + 1);
  uint16_t *data = ms->data;
  for (int i = 0; i < len; i++) {
    if (data[i] < 0x80) {
      ptr[i] = data[i];
    } else {
      ptr[i] = '?';
    }
  }
  ptr[len] = '\0';
  return ptr;
}

struct moonbit_string *c_str_to_moonbit_str(void *ptr) {
  char *cptr = (char *)ptr;
  int32_t len = strlen(cptr);
  struct moonbit_string *ms = moonbit_make_string(len, 0);
  for (int i = 0; i < len; i++) {
    ms->data[i] = (uint16_t)cptr[i];
  }
  return ms;
}
