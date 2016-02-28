=========================================================================
example Memory Map
=========================================================================


meta
---------------------------------------------------------

.. list-table::
   :widths: 10 5 5 15 55
   :header-rows: 1

   *   - Address
       - Bits
       - Mode
       - Shortname
       - What
   *   - ``0x00000000``
       - 32
       - ``p``
       - magic
       - Core-Specific Magic Number (0x0002_1EAF)
   *   - ``0x00000004``
       - 32
       - ``p``
       - version
       - Core version number
   *   - ``0x00000008``
       - 32
       - ``p``
       - feature_flags
       - Feature flags (or zero)
   *   - ``0x0000000C``
       - 32
       - ``p``
       - git_hash
       - HDL Git commit hash stub, or 0 (32bits)
   *   - ``0x00000010``
       - 64
       - ``p``
       - build_time
       - UNIX time of build


general
---------------------------------------------------------

.. list-table::
   :widths: 10 5 5 15 55
   :header-rows: 1

   *   - Address
       - Bits
       - Mode
       - Shortname
       - What
   *   - ``0x00001000``
       - 1
       - ``rw``
       - enable
       - 
   *   - ``0x00001004``
       - 33
       - ``rw``
       - output_en
       - 
   *   - ``0x0000100C``
       - 16
       - ``rw``
       - ring_count
       - Count of doorbell rings
   *   - ``0x00001010``
       - 16
       - ``r``
       - ring_counta
       - Count of doorbell rings
   *   - ``0x00001014``
       - 16
       - ``r``
       - ring_countb
       - Count of doorbell rings

