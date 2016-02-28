#ifndef EXAMPLE_MAP_H
#define EXAMPLE_MAP_H

/* example Memory Map Structs */

/* WARNING: Currently assumes perfect packing */

typedef struct {
    uint32_t magic;
    uint32_t version;
    uint32_t feature_flags;
    uint32_t git_hash;
    uint64_t build_time;
} example_meta_map;
#define example_meta_offset    0x00000000
/* Usage (?)
 *      void *uint32_t example_meta_map...
 */
typedef struct {
    uint32_t enable;
    uint64_t output_en;
    uint32_t ring_count;
    uint32_t ring_counta;
    uint32_t ring_countb;
} example_general_map;
#define example_general_offset    0x00001000
/* Usage (?)
 *      void *uint32_t example_general_map...
 */

#endif