/* ========================================================================
 *
 * n64.ld -- Libdragon linker script
 *
 * Originally based on n64ld.x, developed by Frank Somers <frank@g0dev.com>,
 * with modifications by hcs (halleyscometsoftware@hotmail.com),
 * released under the Unlicense.
 * ========================================================================
 */

OUTPUT_FORMAT ("elf32-ntradbigmips", "elf32-bigmips", "elf32-littlemips")
OUTPUT_ARCH (mips)
EXTERN (_start)
ENTRY (_start)

PHDRS
{
    irq PT_LOAD AT ( 0x80000000 );
    main PT_LOAD AT ( 0x80000400 );
}

SECTIONS {
    .intvectors 0x80000000 : {
        . = ALIGN(32);
        KEEP(*(.intvectors))
        __intvectors_end = .;
    } :irq

    /* The text section carries the app code and its relocation addr is
    * the first byte of the cart domain in cached, unmapped memory
    */
    .text 0x80000400 : {
        *(.boot)
        . = ALIGN(16);
        __text_start = .;
        *(.text)
        *(.text.*)
        *(.init)
        *(.fini)
        *(.gnu.linkonce.t.*)
        . = ALIGN(16);
        __text_end  = .;
    } :main

    /DISCARD/ : {
        *(.eh_frame)
    }

   .gcc_except_table : { *(.gcc_except_table*) } 
   .jcr : { KEEP (*(.jcr)) } 

    .rodata : {
        *(.rdata)
        *(.rodata)
        *(.rodata.*)
        *(.gnu.linkonce.r.*)
        . = ALIGN(8);
    }

    /* This is important to keep __CTOR_END__ consistent */
    . = ALIGN(4);

    .ctors : {
        __CTOR_LIST__ = .;
        /* Actually we should place the count here like;

        LONG((__CTOR_END__ - __CTOR_LIST__) / 4 - 2)

        but g++ seem to already do this (though incorrectly placing an 0xFFFFFFFF)
        and that breaks things if we also add it. Ideally this should be parsed
        by the code but we already know the end as well.

        The new build system links everything via g++ by default and should use
        __wrap___do_global_ctors and enables it via the --wrap linker option.
        When linking with ld, we should use __do_global_ctors, which is the default
        if you don't provide the --wrap option. */
        KEEP(*(.ctors))
         /* Similarly we should have a;

        LONG(0)

        here, and g++ seem to insert it at __CTOR_END__ */
        __CTOR_END__ = .;
    }

    . = ALIGN(8);

    /* Data section has relocation address at start of RAM in cached,
    * unmapped memory, but is loaded just at the end of the text segment,
    * and must be copied to the correct location at startup
    * Gather all initialised data together.  The memory layout
    * will place the global initialised data at the lowest addrs.
    * The lit8, lit4, sdata and sbss sections have to be placed
    * together in that order from low to high addrs with the _gp symbol
    * positioned (aligned) at the start of the sdata section.
    * We then finish off with the standard bss section
    */
    .data : {
        __data_start = .;
        *(.data)
        *(.data.*)
        *(.gnu.linkonce.d.*)
        . = ALIGN(8);
    }

    /* Small data START */

    .sdata : {
        _gp = . + 0x8000;
        *(.sdata)
        *(.sdata.*)
        *(.gnu.linkonce.s.*)
        . = ALIGN(8);
    }

    .lit8 : {
        *(.lit8)
        . = ALIGN(8);
    }
    .lit4 : {
        *(.lit4)
        . = ALIGN(8);
    }

    . = ALIGN(8);
    __data_end = .;

    /* Here the ROM is finished. The rest is just in RAM */
    . = ALIGN(8);
    __rom_end = .;

    .sbss : {
         __bss_start = .;
        *(.sbss)
        *(.sbss.*)
        *(.gnu.linkonce.sb.*)
        *(.scommon)
        *(.scommon.*)
    }

    /* Small data END */

    . = ALIGN(8);
    .bss : {
        *(.bss)
        *(.bss*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
        . = ALIGN(8);
         __bss_end = .;
    }

    . = ALIGN(8);

    /* Deprecated */
    end = .;
}
