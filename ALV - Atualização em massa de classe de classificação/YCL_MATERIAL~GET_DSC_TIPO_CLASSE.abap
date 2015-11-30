*----------------------------------------------------------------------*
*               xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                    *
*----------------------------------------------------------------------*
* Classe   : YCL_MATERIAL                                              *
* Método   : GET_DSC_TIPO_CLASSE                                       *
*----------------------------------------------------------------------*
* ABAP     : Thiago Cordeiro Alves                                     *
* Descrição: Obtém a descrição do tipo da classe                       *
*----------------------------------------------------------------------*
*                   Descrição das Modificações                         *
*----------------------------------------------------------------------*
* Nome      Data        Descrição                                      *
* ACTHIAGO  16.09.2015  #121646 - Desenvolvimento inicial              *
*----------------------------------------------------------------------*

METHOD get_dsc_tipo_classe.

* Denominação do tipo de classe
  SELECT SINGLE artxt
   FROM tclat
   INTO ex_descricao
   WHERE klart = im_classe_material
     AND spras = c_pt_br.

ENDMETHOD.