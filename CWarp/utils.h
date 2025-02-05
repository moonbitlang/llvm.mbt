#include "moonbit.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct moonbit_string *moonbit_make_string(int32_t, uint16_t);

void *moonbit_str_to_c_str(struct moonbit_string *);

struct moonbit_string *c_str_to_moonbit_str(void *ptr);

struct moonbit_string *c_str_to_moonbit_str_with_length(void *ptr,
                                                        unsigned len);
