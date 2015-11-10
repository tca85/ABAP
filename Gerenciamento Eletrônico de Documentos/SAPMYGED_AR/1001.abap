* Gerenciamento Eletrônico de Documentos
* Cadastro de Clientes - Descomprimir sub-tela

PROCESS BEFORE OUTPUT.
  CALL SUBSCREEN sa_1001 INCLUDING sy-repid c_sub_alv_obrig. " 1002

PROCESS AFTER INPUT.
  CALL SUBSCREEN sa_1001.