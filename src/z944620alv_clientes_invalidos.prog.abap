REPORT z944620alv_clientes_invalidos.

TABLES : z944620cli_auto.

DATA : it_z944620cli_auto TYPE STANDARD TABLE OF z944620cli_auto,
       wa_z944620cli_auto TYPE z944620cli_auto.

DATA : it_z944620cli_inconsistentes TYPE STANDARD TABLE OF z944620cli_auto,
       wa_z944620cli_inconsistentes TYPE z944620cli_auto.

DATA: ls_fieldcat TYPE slis_fieldcat_alv,
      lt_fieldcat TYPE STANDARD TABLE OF slis_fieldcat_alv.

DATA : lv_total_clientes        TYPE i,
       lv_total_ativos          TYPE i,
       lv_total_inativos        TYPE i,
       lv_total_status_invalido TYPE i,
       lv_total_cpf_cnpj_vazios TYPE i,
       lv_total_nome_vazios     TYPE i.

START-OF-SELECTION.
  SELECT * FROM z944620cli_auto
    INTO TABLE it_z944620cli_auto.

  LOOP AT it_z944620cli_auto INTO wa_z944620cli_auto.
    lv_total_clientes = lv_total_clientes + 1.

    IF wa_z944620cli_auto-ativo = 'A'.
      lv_total_ativos = lv_total_ativos + 1.
    ELSEIF wa_z944620cli_auto-ativo = 'B'.
      lv_total_inativos = lv_total_inativos + 1.
    ELSE.
      lv_total_status_invalido = lv_total_status_invalido + 1.
      APPEND wa_z944620cli_auto to it_z944620cli_inconsistentes.
    ENDIF.

    IF wa_z944620cli_auto-cpf_cnpj = ''.
      lv_total_cpf_cnpj_vazios = lv_total_cpf_cnpj_vazios + 1.
      APPEND wa_z944620cli_auto to it_z944620cli_inconsistentes.
    ENDIF.

    IF wa_z944620cli_auto-nome_cliente = ''.
      lv_total_nome_vazios = lv_total_nome_vazios + 1.
      APPEND wa_z944620cli_auto to it_z944620cli_inconsistentes.
    ENDIF.
  ENDLOOP.

  WRITE 'Total de clientes cadastrados: '.
  WRITE |{ lv_total_clientes }|.

  NEW-LINE.
  WRITE 'Total de clientes ativos: '.
  WRITE |{ lv_total_ativos }|.

  NEW-LINE.
  WRITE 'Total de clientes inativos: '.
  WRITE |{ lv_total_inativos }|.

  NEW-LINE.
  WRITE 'Total de clientes com STATUS inválido: '.
  WRITE |{ lv_total_status_invalido }|.

  NEW-LINE.
  WRITE 'Total de clientes com CPF/CNPJ em branco: '.
  WRITE |{ lv_total_cpf_cnpj_vazios }|.

  NEW-LINE.
  WRITE 'Total de clientes com nome em branco: '.
  WRITE |{ lv_total_nome_vazios }|.

*-------------------------------------------------------------------------------------
* Relatório ALV
*-------------------------------------------------------------------------------------

  CLEAR lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CLIENTE_ID'.
  ls_fieldcat-seltext_m = 'ID Cliente'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NOME_CLIENTE'.
  ls_fieldcat-seltext_m = 'Nome'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TIPO_CLIENTE'.
  ls_fieldcat-seltext_m = 'Tipo'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CPF_CNPJ'.
  ls_fieldcat-seltext_m = 'CPF/CNPJ'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'EMAIL'.
  ls_fieldcat-seltext_m = 'E-mail'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TELEFONE'.
  ls_fieldcat-seltext_m = 'Telefone'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MARCA_PREFERIDA'.
  ls_fieldcat-seltext_m = 'Marca Preferida'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MODELO_INTERESSE'.
  ls_fieldcat-seltext_m = 'Modelo Interesse'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATA_CADASTRO'.
  ls_fieldcat-seltext_m = 'Data Cadastro'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ATIVO'.
  ls_fieldcat-seltext_m = 'Status'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Chamada do ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_grid_title       = 'Clientes com Registro Inválido'
      it_fieldcat        = lt_fieldcat
      i_save             = 'X'
    TABLES
      t_outtab           = it_z944620cli_inconsistentes
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
