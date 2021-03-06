------------------------------------------------------------------------
--
--                   "DHRYSTONE" Benchmark Program
--                   -----------------------------
--                                                                            
--  Version:    Ada, Version 2.1
--                                                                            
--  File:       d_global.s (part 1 of 6)
--
--  Date:       December 17, 1988
--
--  Author:     Reinhold P. Weicker
--                      Siemens AG, AUT E 51
--                      Postfach 3220
--                      8520 Erlangen
--                      Germany (West)
--                              Phone:  [+49]-9131-7-20330
--                                      (8-17 Central European Time)
--                              Usenet: ..!mcsun!unido!estevax!weicker
--
--              Original Version published in "Communications of the ACM"
--		vol. 27., no. 10 (Oct. 1984), pp. 1013 - 1030,
--              together with the statistics on which the distribution
--		of statements etc. is based.
--
--              In this Ada version, the predefined package TEXT_IO
--		is used for Input/Output. For portability, only
--		Standard Ada language features are used for time
--		measaurement. This means that the procedure "Clock" of
--		package CALENDAR is used to measure the time,
--		even though it returns the elapsed time and not the CPU time.
--		See comments in d_pack_1.b for a discussion of
--		time measurement methods.
--
--  Collection of Results:
--              Reinhold Weicker (address see above) and
--              
--              Rick Richardson
--              PC Research. Inc.
--              94 Apple Orchard Drive
--              Tinton Falls, NJ 07724
--                      Phone:  (201) 389-8963 (9-17 EST)               
--                      Usenet: ...!uunet!pcrat!rick
--
--      Please send results to Reinhold Weicker and Rick Richardson.
--      Complete information should be given on hardware and software used.
--      Hardware information includes: Machine type, CPU, type and size
--      of caches; for microprocessors: clock frequency, memory speed
--      (number of wait states).
--      Software information includes: Compiler (and runtime library)
--      manufacturer and version, compilation switches, OS version.
--      The Operating System version may give an indication about the
--      compiler; Dhrystone itself performs no OS calls in the measurement loop.
--
--      The complete output generated by the program should be mailed
--      such that at least some checks for correctness can be made.
--
------------------------------------------------------------------------
--
--  History:    This version Ada/2.1 has been made for two reasons:
--
--              1) As far as it is possible without changes to the Dhrystone
--              statistics, optimizing compilers should be prevented from
--              removing significant statements.
--
--              2) With the new (2.1) C and Pascal versions, there should
--		be a corresponding Ada version. Also, the Ada version of
--		Dhrystone has not yet found a network distribution comparable
--		to the C version (version 1.1) distributed by Rick Richardson.
--             
--              This Ada version 2.1 has been made consistent with the
--              C version 2.1; therefore the acknowledgments for the C version
--              are due for the Ada version as well: I thank
--              Rick Richardson (Tinton Falls, NJ), Chaim Benedelac (Nat.
--              Semi.), David Ditzel (SUN), Earl Killian and John Mashey (MIPS),
--              Alan Smith and Rafael Saavedra-Barrera (UC at Berkeley)
--              for their help with comments on earlier versions of the
--              benchmark.
--
--  Changes:    In the initialization part, this version follows mostly
--              Rick Richardson's C version distributed via Usenet, not the
--              version distributed earlier via floppy disk by Reinhold Weicker.
--              Inside the measurement loop, this version follows the
--              version previously distributed by Reinhold Weicker.
--
--              At several places in the benchmark, code has been added,
--              but within the measurement loop only in branches that 
--              are not executed. The intention is that optimizing compilers
--              should be prevented from moving code out of the measurement
--              loop, or from removing code altogether. Since the statements
--              that are executed within the measurement loop have NOT been
--              changed, the numbers defining the "Dhrystone distribution"
--              (distribution of statements, operand types and locality)
--              still hold. Except for sophisticated optimizing compilers,
--              execution times for this version should be the same as
--              for previous versions.
--              
--		Since it has proven difficult to subtract the time for the
--		measurement loop overhead in a correct way, the loop check
--		has been made a part of the benchmark. This does have
--		an impact - though a very minor one - on the distribution
--		statistics which have been updated for this version.
--
--              All changes within the measurement loop are described
--              and discussed in the companion paper "Rationale for
--              Dhrystone version 2".
--
--              Because of the self-imposed limitation that the order and
--              distribution of the executed statements should not be
--              changed, there are still cases where optimizing compilers
--              may not generate code for some statements. To a certain
--              degree, this is unavoidable for small synthetic benchmarks.
--              Users of the benchmark are advised to check code listings
--              whether code is generated for all statements of Dhrystone.
--
------------------------------------------------------------------------
--
--  Compilation model and measurement (IMPORTANT):
--
--  This Ada version of Dhrystone consists of six files
--  (file names shortened to 8 characters for MS-DOS floppy disk distribution):
--
--  - d_global.s (this file, containing global definitions and comments)
--  - d_pack_1.s (containing the package specification of Pack_1)
--  - d_pack_2.s (containing the package specification of Pack_2)
--  - d_pack_1.b (containing the package body of Pack_1)
--  - d_pack_2.b (containing the package body of Pack_2)
--  - d_main.b (containing procedure "main", very short)
--
--  The following "ground rules" apply for measurements:
--  - Separate compilation
--  - No procedure merging
--  - Otherwise, compiler optimizations are allowed but should be indicated
--  - Default results are those without register declarations
--  See the companion paper "Rationale for Dhrystone Version 2" for a more
--  detailed discussion of these ground rules.
--
--  For 16-Bit processors (e.g. 80186, 80286), times for all compilation
--  models ("small", "medium", "large" etc.) should be given if possible,
--  together with a definition of these models for the compiler system used.
--
--------------------------------------------------------------------------------
--
--  [Comment from the first distribution, still valid in principle.
--   Note that because of the inclusion of the measurement loop iteration,
--   the numbers are slightly different from the published version.]
--
--  The following program contains statements of a high level programming
--  language (here: Ada) in a distribution considered representative:
--
--    assignments                  53 %
--    control statements           32 %
--    procedure, function calls    15 %
--
--  100 statements are dynamically executed. The program is balanced with
--  respect to the three aspects:
--
--    - statement type
--    - operand type (for simple data types)
--    - operand access
--         operand global, local, parameter, or constant.
--
--  The combination of these three aspects is balanced only approximately.
--
--  1. Statement Type:
--  -----------------             number
--
--     V1 := V2                   10
--     V := Constant              12
--       (incl. V1 := F(
--     Assignment,                 7
--       with array element
--     Assignment,                 6
--       with record component
--                                --
--                                35       35
--
--     X := Y +|-|and|or Z         5
--     X := Y +|-|"=" Constant     6
--     X := X +|- 1                3
--     X := Y *|/ Z                2
--     X := Expression,            1
--          two operators
--     X := Expression,            1
--          three operators
--                                --
--                                18       18
--
--     if .... then ....          14
--       with "else"      7
--       without "else"   7
--           executed        3
--           not executed    4
--     for  ...  loop              7  |  counted every time
--     while ... loop              4  |  the loop condition
--     loop .... exit              1  |  is evaluated
--     case ... end case           1
--     return                      5
--     rename                      1
--                                --
--                                33       33
--
--     P (...)  proced. call      10
--       same package        5
--       other package       5
--
--     X := F (
--          function  call         5
--       same package        2
--       other package       3
--                                --
--                                15       15
--                                        ---
--                                        101
--
--    22 of the 58 assignments have a variable of a constrained
--    (sub-)type as their destination. In general, discriminant checks
--    will be necessary in these cases; however, the compiler may
--    optimize out some of these checks.
--
--    The average number of parameters in procedure or function calls
--    is 1.80 (not counting the function values as implicit parameters)
--
--
--  2. Operators
--  ------------
--                          number    approximate
--                                    percentage
--
--    Arithmetic             27          52.9
--
--       +                     16          31.4
--       -                      7          13.7
--       *                      3           5.9
--       /                      1           2.0
--
--    Comparison             20           39.2
--
--       =                      9           17.6
--       /=                     4            7.8
--       >                      1            2.0
--       <                      3            5.9
--       >=                     1            2.0
--       <=                     2            3.9
--
--    Logic                   4            7.8
--
--       AND                    1            2.0
--       OR                     1            2.0
--       NOT                    2            3.9
--
--                           --          -----
--                           51           99.9
--
--
--  3. Operand Type (counted once per operand reference)
--  ---------------
--                          number    approximate
--                                    percentage
--
--     Integer               135        55.1 %
--     Character              47        19.2 %
--     Enumeration            30        12.2 %
--     Boolean                11         4.5 %
--     Pointer                12         5.0 %
--     String30                6         2.4 %
--     Array                   2         0.8 %
--     Record                  2         0.8 %
--                           ---       -------
--                           245       100.0 %
--
--  When there is an access path leading to the final operand (e.g. a record
--  component), only the final data type on the access path is counted.
--
--  There are 16 accesses to components of a record, 9 of them go to
--  a component in a variant part. For some of these accesses, the
--  compiler may suppress generation of code checking the tag field
--  during optimization.
--
--
--  3. Operand Locality:
--  -------------------
--
--     local variable              120        49.0 %
--     global variable              20         8.2 %
--        same package                 19          7.8 %
--        other package                 1          0.4 %
--     parameter                    45        18.3 %
--        in                           27         11.0 %
--        inout                        12          5.0 %
--        out                           6          2.4 %
--     function result               5         2.0 %
--     constant                     55        22.4 %
--                                 ---       -------
--                                 245        99.9 %
--
--
--  There may be cases where a highly optimizing compiler may recognize
--  unnecessary statements and may not generate code for them.
--
--  There has been no explicit effort to account for the effects of a
--  cache, or to balance the use of long or short displacements for code or
--  data.
--
--  The program does not compute anything meaningful, but it is syntactically
--  and semantically correct. All variables have a value assigned to them
--  before they are used as a source operand.
--
--------------------------------------------------------------------------------

package Global_Def is
------------------

  -- Global type definitions

  type Enumeration is (Ident_1, Ident_2, Ident_3, Ident_4, Ident_5);

  subtype One_To_Thirty is integer range 1..30;
  subtype One_To_Fifty is integer range 1..50;
  subtype Capital_Letter is character range 'A'..'Z';

  type String_30 is array (One_To_Thirty) of character;
    pragma Pack (String_30);
    -- This pragma may be omitted if it leads to a packing of a character
    -  in less than an 8-bit byte.

  type Array_1_Dim_Integer is array (One_To_Fifty) of integer;
  type Array_2_Dim_Integer is array (One_To_Fifty,
                                     One_To_Fifty) of integer;

  type Record_Type (Discr: Enumeration := Ident_1);
  type Record_Pointer is access Record_Type;

  type Record_Type (Discr: Enumeration := Ident_1) is
               record
                Pointer_Comp:   Record_Pointer;
                case Discr is
                  when Ident_1 =>     -- only this variant is used,
                                      -- but in some cases discriminant
                                      -- checks are necessary
                    Enum_Comp:      Enumeration;
                    Int_Comp:       One_To_Fifty;
                    String_Comp:    String_30;
                  when Ident_2 =>
                    Enum_Comp_2:    Enumeration;
                    String_Comp_2:  String_30;
                  when others =>
                    Char_Comp_1,
                    Char_Comp_2:    character;
                end case;
              end record;

end Global_Def;
