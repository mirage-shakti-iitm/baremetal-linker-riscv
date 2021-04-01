/* taken (and modified) from riscv-pk. See LICENSE.riscv-pk */

OUTPUT_ARCH( "riscv" )

ENTRY( reset_vector )

SECTIONS
{
    . = 0x10000000;

    .text : {
         KEEP(*(.text.init))
         /* cpp support:
          * constructors, need to be aligned by 2 bytes.
          * otherwise *ctor() crashes with an oob memory
          * access */
         . = ALIGN(16);
         PROVIDE(__CTORS_START = .);
         KEEP (*(.ctors*))
         KEEP (*(.init_array*))
         PROVIDE(__CTORS_END = .);

         *(.text)
         *(.text.*)
         *(.gnu.linkonce.t.*)
    }

  . = ALIGN(16);
/* rodata: Read-only data */
  .rodata :
  {
    PROVIDE( _srodata = . );
    *(.rdata)
    *(.rodata)
    *(.rodata.*)
    *(.gnu.linkonce.r.*)
    PROVIDE( _erodata = . );
  }

  /*--------------------------------------------------------------------*/
  /* HTIF, isolated onto separate page                                  */
  /*--------------------------------------------------------------------*/
  . = ALIGN(0x1000);
  .htif :
  {
    PROVIDE( __htif_base = . );
    *(.htif)
  }
  . = ALIGN(0x1000);


  /*--------------------------------------------------------------------*/
  /* Initialized data segment                                           */
  /*--------------------------------------------------------------------*/

  /* Start of initialized data segment */
  . = ALIGN(16);
   _fdata = .;

  /* data: Writable data */
  .data :
  {
  *(.data)
  *(.data.*)
  *(.srodata*)
  *(.gnu.linkonce.d.*)
  *(.comment)
  }

  /* End of initialized data segment */
  PROVIDE( edata = . );
  _edata = .;

  /* Have _gp point to middle of sdata/sbss to maximize displacement range */
  . = ALIGN(16);
  _gp = . + 0x800;

  /* Writable small data segment */
  .sdata :
  {
    *(.sdata)
    PROVIDE( _impure_ptr = . );
    _impure_ptr = .;
    *(.sdata.*)
    *(.srodata.*)
    *(.gnu.linkonce.s.*)
  }

  /*--------------------------------------------------------------------*/
  /* Uninitialized data segment                                         */
  /*--------------------------------------------------------------------*/

  /* Start of uninitialized data segment */
  . = ALIGN(8);
  _fbss = .;

  /* Writable uninitialized small data segment */
  .sbss :
  {
    *(.sbss)
    *(.sbss.*)
    *(.gnu.linkonce.sb.*)
  }

  /* bss: Uninitialized writeable data section */
  . = .;
  _bss_start = .;
  .bss :
  {
    *(.bss)
    *(.bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
  }
  _bss_end = .;
  _ebss = .;


  _end = ALIGN(8);
  /* End of uninitialized data segment
   * used for heap allocation
   */ 
  PROVIDE( __KERNEL_END = . );
  __KERNEL_END = .;
}
