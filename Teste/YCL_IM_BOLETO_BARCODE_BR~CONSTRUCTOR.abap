METHOD constructor .

  DATA:
    ls_dectobin TYPE mty_dectobin,
    ls_bintoshorter TYPE mty_bintoshorter.


* Compute number of bits to represent mc_base
  mv_basedigits = LOG10( mc_base ) / LOG10( 2 ).

* ---------------------------------------------------------------------
* Fill conversion table dec -> bin
* ---------------------------------------------------------------------
  ls_dectobin-dec_digit = '0'.
  ls_dectobin-bin_digits = '0000'.
  APPEND ls_dectobin TO mt_dectobin.

  ls_dectobin-dec_digit = '1'.
  ls_dectobin-bin_digits = '0001'.
  APPEND ls_dectobin TO mt_dectobin.

  ls_dectobin-dec_digit = '2'.
  ls_dectobin-bin_digits = '0010'.
  APPEND ls_dectobin TO mt_dectobin.

  ls_dectobin-dec_digit = '3'.
  ls_dectobin-bin_digits = '0011'.
  APPEND ls_dectobin TO mt_dectobin.

  ls_dectobin-dec_digit = '4'.
  ls_dectobin-bin_digits = '0100'.
  APPEND ls_dectobin TO mt_dectobin.

  ls_dectobin-dec_digit = '5'.
  ls_dectobin-bin_digits = '0101'.
  APPEND ls_dectobin TO mt_dectobin.

  ls_dectobin-dec_digit = '6'.
  ls_dectobin-bin_digits = '0110'.
  APPEND ls_dectobin TO mt_dectobin.

  ls_dectobin-dec_digit = '7'.
  ls_dectobin-bin_digits = '0111'.
  APPEND ls_dectobin TO mt_dectobin.

  ls_dectobin-dec_digit = '8'.
  ls_dectobin-bin_digits = '1000'.
  APPEND ls_dectobin TO mt_dectobin.

  ls_dectobin-dec_digit = '9'.
  ls_dectobin-bin_digits = '1001'.
  APPEND ls_dectobin TO mt_dectobin.


* ---------------------------------------------------------------------
* Fill conversion table bin -> number system specified in mc_base
* ---------------------------------------------------------------------
  ls_bintoshorter-bin_digits = '00000'.
  ls_bintoshorter-con_digit  = '0'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '00001'.
  ls_bintoshorter-con_digit  = '1'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '00010'.
  ls_bintoshorter-con_digit  = '2'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '00011'.
  ls_bintoshorter-con_digit  = '3'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '00100'.
  ls_bintoshorter-con_digit  = '4'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '00101'.
  ls_bintoshorter-con_digit  = '5'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '00110'.
  ls_bintoshorter-con_digit  = '6'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '00111'.
  ls_bintoshorter-con_digit  = '7'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '01000'.
  ls_bintoshorter-con_digit  = '8'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '01001'.
  ls_bintoshorter-con_digit  = '9'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '01010'.
  ls_bintoshorter-con_digit  = 'A'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '01011'.
  ls_bintoshorter-con_digit  = 'B'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '01100'.
  ls_bintoshorter-con_digit  = 'C'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '01101'.
  ls_bintoshorter-con_digit  = 'D'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '01110'.
  ls_bintoshorter-con_digit  = 'E'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '01111'.
  ls_bintoshorter-con_digit  = 'F'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '10000'.
  ls_bintoshorter-con_digit  = 'G'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '10001'.
  ls_bintoshorter-con_digit  = 'H'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '10010'.
  ls_bintoshorter-con_digit  = 'I'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '10011'.
  ls_bintoshorter-con_digit  = 'J'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '10100'.
  ls_bintoshorter-con_digit  = 'K'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '10101'.
  ls_bintoshorter-con_digit  = 'L'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '10110'.
  ls_bintoshorter-con_digit  = 'M'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '10111'.
  ls_bintoshorter-con_digit  = 'N'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '11000'.
  ls_bintoshorter-con_digit  = 'O'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '11001'.
  ls_bintoshorter-con_digit  = 'P'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '11010'.
  ls_bintoshorter-con_digit  = 'Q'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '11011'.
  ls_bintoshorter-con_digit  = 'R'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '11100'.
  ls_bintoshorter-con_digit  = 'S'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '11101'.
  ls_bintoshorter-con_digit  = 'T'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '11110'.
  ls_bintoshorter-con_digit  = 'U'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

  ls_bintoshorter-bin_digits = '11111'.
  ls_bintoshorter-con_digit  = 'V'.
  APPEND ls_bintoshorter TO mt_bintoshorter.

ENDMETHOD.