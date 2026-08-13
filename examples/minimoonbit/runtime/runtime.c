
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef struct {
  int32_t length;
  int32_t capacity; // default: length * 2 + 1
  int32_t *data;
} IntArray;

typedef struct {
  int32_t length;
  int32_t capacity; // default: length * 2 + 1
  int64_t *data;
} Int64Array;

typedef struct {
  int32_t length;
  int32_t capacity; // default: length * 2 + 1
  uint32_t *data;
} UIntArray;

typedef struct {
  int32_t length;
  int32_t capacity; // default: length * 2 + 1
  uint64_t *data;
} UInt64Array;

typedef struct {
  int32_t length;
  int32_t capacity; // default: length * 2 + 1
  double *data;
} DoubleArray;

typedef struct {
  int32_t length;
  int32_t capacity; // default: length * 2 + 1
  float *data;
} FloatArray;

typedef struct {
  int32_t length;
  int32_t capacity; // default: length * 2 + 1
  uint8_t *data;
} BoolArray;

typedef struct {
  int32_t length;
  int32_t capacity; // default: length * 2 + 1
  char *data;
} CharArray;

typedef struct {
  int32_t length;
  int32_t capacity; // default: length * 2 + 1
  void **data;
} PtrArray;

typedef struct {
  char *data;
  int32_t length;
} MoonBitStr;

void* moonbit_malloc(int32_t size) {
  return malloc(size);
}

void* moonbit_realloc(void *ptr, size_t size) {
  return realloc(ptr, size);
}

IntArray* make_int_array(int32_t length, int32_t init_value) {
  IntArray *arr = (IntArray *)moonbit_malloc(sizeof(IntArray));
  arr->length = length;
  arr->capacity = length * 2 + 1;
  arr->data = (int32_t *)moonbit_malloc(arr->capacity * sizeof(int32_t));
  for (int32_t i = 0; i < length; i++) {
    arr->data[i] = init_value;
  }
  return arr;
}

Int64Array* make_int64_array(int32_t length, int64_t init_value) {
  Int64Array *arr = (Int64Array *)moonbit_malloc(sizeof(Int64Array));
  arr->length = length;
  arr->capacity = length * 2 + 1;
  arr->data = (int64_t *)moonbit_malloc(arr->capacity * sizeof(int64_t));
  for (int32_t i = 0; i < length; i++) {
    arr->data[i] = init_value;
  }
  return arr;
}

UIntArray* make_uint_array(int32_t length, uint32_t init_value) {
  UIntArray *arr = (UIntArray *)moonbit_malloc(sizeof(UIntArray));
  arr->length = length;
  arr->capacity = length * 2 + 1;
  arr->data = (uint32_t *)moonbit_malloc(arr->capacity * sizeof(uint32_t));
  for (int32_t i = 0; i < length; i++) {
    arr->data[i] = init_value;
  }
  return arr;
}

UInt64Array* make_uint64_array(int32_t length, uint64_t init_value) {
  UInt64Array *arr = (UInt64Array *)moonbit_malloc(sizeof(UInt64Array));
  arr->length = length;
  arr->capacity = length * 2 + 1;
  arr->data = (uint64_t *)moonbit_malloc(arr->capacity * sizeof(uint64_t));
  for (int32_t i = 0; i < length; i++) {
    arr->data[i] = init_value;
  }
  return arr;
}

DoubleArray* make_double_array(int32_t length, double init_value) {
  DoubleArray *arr = (DoubleArray *)moonbit_malloc(sizeof(DoubleArray));
  arr->length = length;
  arr->capacity = length * 2 + 1;
  arr->data = (double *)moonbit_malloc(arr->capacity * sizeof(double));
  for (int32_t i = 0; i < length; i++) {
    arr->data[i] = init_value;
  }
  return arr;
}

FloatArray* make_float_array(int32_t length, float init_value) {
  FloatArray *arr = (FloatArray *)moonbit_malloc(sizeof(FloatArray));
  arr->length = length;
  arr->capacity = length * 2 + 1;
  arr->data = (float *)moonbit_malloc(arr->capacity * sizeof(float));
  for (int32_t i = 0; i < length; i++) {
    arr->data[i] = init_value;
  }
  return arr;
}

BoolArray* make_bool_array(int32_t length, uint8_t init_value) {
  BoolArray *arr = (BoolArray *)moonbit_malloc(sizeof(BoolArray));
  arr->length = length;
  arr->capacity = length * 2 + 1;
  arr->data = (uint8_t *)moonbit_malloc(arr->capacity * sizeof(uint8_t));
  for (int32_t i = 0; i < length; i++) {
    arr->data[i] = init_value;
  }
  return arr;
}

CharArray* make_char_array(int32_t length, char init_value) {
  CharArray *arr = (CharArray *)moonbit_malloc(sizeof(CharArray));
  arr->length = length;
  arr->capacity = length * 2 + 1;
  arr->data = (char *)moonbit_malloc(arr->capacity * sizeof(char));
  for (int32_t i = 0; i < length; i++) {
    arr->data[i] = init_value;
  }
  return arr;
}

PtrArray* make_ptr_array(int32_t length, void *init_value) {
  PtrArray *arr = (PtrArray *)moonbit_malloc(sizeof(PtrArray));
  arr->length = length;
  arr->capacity = length * 2 + 1;
  arr->data = (void **)moonbit_malloc(arr->capacity * sizeof(void *));
  for (int32_t i = 0; i < length; i++) {
    arr->data[i] = init_value;
  }
  return arr;
}

int32_t get_array_length(void *array) {
  return *((int32_t *)array);
}

void array_int_push(IntArray *arr, int32_t value) {
  if (arr->length >= arr->capacity) {
    arr->capacity = arr->capacity * 2 + 1;
    arr->data = (int32_t *)moonbit_realloc(arr->data, arr->capacity * sizeof(int32_t));
  }
  arr->data[arr->length++] = value;
}

void array_int64_push(Int64Array *arr, int64_t value) {
  if (arr->length >= arr->capacity) {
    arr->capacity = arr->capacity * 2 + 1;
    arr->data = (int64_t *)moonbit_realloc(arr->data, arr->capacity * sizeof(int64_t));
  }
  arr->data[arr->length++] = value;
}

void array_uint_push(UIntArray *arr, uint32_t value) {
  if (arr->length >= arr->capacity) {
    arr->capacity = arr->capacity * 2 + 1;
    arr->data = (uint32_t *)moonbit_realloc(arr->data, arr->capacity * sizeof(uint32_t));
  }
  arr->data[arr->length++] = value;
}

void array_uint64_push(UInt64Array *arr, uint64_t value) {
  if (arr->length >= arr->capacity) {
    arr->capacity = arr->capacity * 2 + 1;
    arr->data = (uint64_t *)moonbit_realloc(arr->data, arr->capacity * sizeof(uint64_t));
  }
  arr->data[arr->length++] = value;
}

void array_double_push(DoubleArray *arr, double value) {
  if (arr->length >= arr->capacity) {
    arr->capacity = arr->capacity * 2 + 1;
    arr->data = (double *)moonbit_realloc(arr->data, arr->capacity * sizeof(double));
  }
  arr->data[arr->length++] = value;
}

void array_float_push(FloatArray *arr, float value) {
  if (arr->length >= arr->capacity) {
    arr->capacity = arr->capacity * 2 + 1;
    arr->data = (float *)moonbit_realloc(arr->data, arr->capacity * sizeof(float));
  }
  arr->data[arr->length++] = value;
}

void array_bool_push(BoolArray *arr, uint8_t value) {
  if (arr->length >= arr->capacity) {
    arr->capacity = arr->capacity * 2 + 1;
    arr->data = (uint8_t *)moonbit_realloc(arr->data, arr->capacity * sizeof(uint8_t));
  }
  arr->data[arr->length++] = value;
}

void array_char_push(CharArray *arr, char value) {
  if (arr->length >= arr->capacity) {
    arr->capacity = arr->capacity * 2 + 1;
    arr->data = (char *)moonbit_realloc(arr->data, arr->capacity * sizeof(char));
  }
  arr->data[arr->length++] = value;
}

void array_ptr_push(PtrArray *arr, void *value) {
  if (arr->length >= arr->capacity) {
    arr->capacity = arr->capacity * 2 + 1;
    arr->data = (void **)moonbit_realloc(arr->data, arr->capacity * sizeof(void *));
  }
  arr->data[arr->length++] = value;
}

int array_int_get(IntArray *arr, int32_t index) {
  return arr->data[index];
}

int64_t array_int64_get(Int64Array *arr, int32_t index) {
  return arr->data[index];
}

uint32_t array_uint_get(UIntArray *arr, int32_t index) {
  return arr->data[index];
}

uint64_t array_uint64_get(UInt64Array *arr, int32_t index) {
  return arr->data[index];
}

double array_double_get(DoubleArray *arr, int32_t index) {
  return arr->data[index];
}

float array_float_get(FloatArray *arr, int32_t index) {
  return arr->data[index];
}

uint8_t array_bool_get(BoolArray *arr, int32_t index) {
  return arr->data[index];
}

char array_char_get(CharArray *arr, int32_t index) {
  return arr->data[index];
}

void* array_ptr_get(PtrArray *arr, int32_t index) {
  return arr->data[index];
}

void array_int_put(IntArray *arr, int32_t index, int32_t value) {
  arr->data[index] = value;
}

void array_int64_put(Int64Array *arr, int32_t index, int64_t value) {
  arr->data[index] = value;
}

void array_uint_put(UIntArray *arr, int32_t index, uint32_t value) {
  arr->data[index] = value;
}

void array_uint64_put(UInt64Array *arr, int32_t index, uint64_t value) {
  arr->data[index] = value;
}

void array_double_put(DoubleArray *arr, int32_t index, double value) {
  arr->data[index] = value;
}

void array_float_put(FloatArray *arr, int32_t index, float value) {
  arr->data[index] = value;
}

void array_bool_put(BoolArray *arr, int32_t index, uint8_t value) {
  arr->data[index] = value;
}

void array_char_put(CharArray *arr, int32_t index, char value) {
  arr->data[index] = value;
}

void array_ptr_put(PtrArray *arr, int32_t index, void *value) {
  arr->data[index] = value;
}

void moonbit_main(void);

void print_int(int value) {
  printf("%d", value);
}

void print_bool(uint8_t value) {
  if (value) {
    printf("true");
  } else {
    printf("false");
  }
}

void print_string(MoonBitStr *str) {
  if (str == NULL || str->data == NULL) {
    return;
  }
  printf("%s", str->data);
}

int int_of_float(double value) {
  return (int)value;
}

double float_of_int(int32_t value) {
  return (double)value;
}

double abs_float(double value) {
  return value < 0 ? -value : value;
}

int32_t truncate(double value) {
  return (int32_t)value;
}

void print_endline(void) {
  printf("\n");
}

void __builtin_println_int(int value) {
  printf("%d\n", value);
}

void __builtin_println_bool(uint8_t value) {
  if (value) {
    printf("true\n");
  } else {
    printf("false\n");
  }
}

void __builtin_println_string(MoonBitStr *str) {
  if (str == NULL || str->data == NULL) {
    printf("\n");
    return;
  }
  printf("%s\n", str->data);
}

void __builtin_println_double(double value) {
  printf("%f\n", value);
}

void __builtin_println_int64(int64_t value) {
  printf("%lld\n", (long long)value);
}

void __builtin_println_uint(uint32_t value) {
  printf("%u\n", value);
}

void __builtin_println_uint64(uint64_t value) {
  printf("%llu\n", (unsigned long long)value);
}

void __builtin_println_float(float value) {
  printf("%f\n", value);
}

void __builtin_println_char(char value) {
  printf("%c\n", value);
}

void __builtin_print_int(int value) {
  printf("%d", value);
}

void __builtin_print_int64(int64_t value) {
  printf("%lld", (long long)value);
}

void __builtin_print_uint(uint32_t value) {
  printf("%u", value);
}

void __builtin_print_uint64(uint64_t value) {
  printf("%llu", (unsigned long long)value);
}

void __builtin_print_float(float value) {
  printf("%f", value);
}

void __builtin_print_char(char value) {
  printf("%c", value);
}

void __builtin_print_bool(uint8_t value) {
  if (value) {
    printf("true");
  } else {
    printf("false");
  }
}

void __builtin_print_string(MoonBitStr *str) {
  if (str == NULL || str->data == NULL) {
    return;
  }
  printf("%s", str->data);
}

void __builtin_print_double(double value) {
  printf("%f", value);
}

MoonBitStr* __builtin_create_string(const char* str) {
  MoonBitStr *moonbit_str = (MoonBitStr *)moonbit_malloc(sizeof(MoonBitStr));
  int len = 0;
  while (str[len] != '\0') {
    len++;
  }
  moonbit_str->length = len;
  moonbit_str->data = (char *)moonbit_malloc((len + 1) * sizeof(char));
  for (int i = 0; i < len; i++) {
    moonbit_str->data[i] = str[i];
  }
  moonbit_str->data[len] = '\0';
  return moonbit_str;
}

int32_t __builtin_get_string_length(MoonBitStr* str) {
  return str->length;
}

MoonBitStr* __builtin_string_concat(MoonBitStr* str1, MoonBitStr* str2) {
  MoonBitStr *result = (MoonBitStr *)moonbit_malloc(sizeof(MoonBitStr));
  result->length = str1->length + str2->length;
  result->data = (char *)moonbit_malloc((result->length + 1) * sizeof(char));
  for (int i = 0; i < str1->length; i++) {
    result->data[i] = str1->data[i];
  }
  for (int i = 0; i < str2->length; i++) {
    result->data[str1->length + i] = str2->data[i];
  }
  result->data[result->length] = '\0';
  return result;
}

char __builtin_get_char_in_string(MoonBitStr* str, int32_t index) {
  return str->data[index];
}

uint8_t moonbit_string_eq(MoonBitStr* str1, MoonBitStr* str2) {
  if (str1->length != str2->length) {
    return 0; // not equal
  }
  for (int i = 0; i < str1->length; i++) {
    if (str1->data[i] != str2->data[i]) {
      return 0; // not equal
    }
  }
  return 1; // equal
}

MoonBitStr* __builtin_int_to_string(int32_t value) {
  char buffer[32];
  snprintf(buffer, sizeof(buffer), "%d", value);
  return __builtin_create_string(buffer);
}

MoonBitStr* __builtin_int64_to_string(int64_t value) {
  char buffer[64];
  snprintf(buffer, sizeof(buffer), "%lld", (long long)value);
  return __builtin_create_string(buffer);
}

MoonBitStr* __builtin_uint_to_string(uint32_t value) {
  char buffer[32];
  snprintf(buffer, sizeof(buffer), "%u", value);
  return __builtin_create_string(buffer);
}

MoonBitStr* __builtin_uint64_to_string(uint64_t value) {
  char buffer[64];
  snprintf(buffer, sizeof(buffer), "%llu", (unsigned long long)value);
  return __builtin_create_string(buffer);
}

MoonBitStr* __builtin_float_to_string(float value) {
  char buffer[64];
  snprintf(buffer, sizeof(buffer), "%.17g", value);
  return __builtin_create_string(buffer);
}

MoonBitStr* __builtin_double_to_string(double value) {
  char buffer[64];
  snprintf(buffer, sizeof(buffer), "%.9g", value);
  return __builtin_create_string(buffer);
}

MoonBitStr* __builtin_char_to_string(char value) {
  char buffer[2];
  buffer[0] = value;
  buffer[1] = '\0';
  return __builtin_create_string(buffer);
}

int main(void) {
  moonbit_main();
  return 0;
}

