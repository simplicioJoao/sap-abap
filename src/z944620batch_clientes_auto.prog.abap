REPORT z944620batch_clientes_auto.



TABLES: sscrfields, z944620cli_auto.

DATA: lt_file_table TYPE filetable,
      lv_rc         TYPE i,
      lv_filename   TYPE string,
      lt_data       TYPE STANDARD TABLE OF string,
      lv_line       TYPE string,
      lt_split      TYPE STANDARD TABLE OF string,
      lv_field      TYPE string,
      opt           TYPE ctu_params.

DATA: lt_clientes TYPE STANDARD TABLE OF z944620cli_auto,
      ls_cliente  TYPE z944620cli_auto.

DATA: lt_bdcdata TYPE STANDARD TABLE OF bdcdata,
      ls_bdcdata TYPE bdcdata.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_file TYPE string.
  SELECTION-SCREEN PUSHBUTTON /1(20) btn_file USER-COMMAND sel_file.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  btn_file = 'Selecionar Arquivo'.

AT SELECTION-SCREEN.
  IF sscrfields-ucomm = 'SEL_FILE'.
    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        window_title = 'Escolha um arquivo CSV'
        file_filter  = 'CSV files (*.csv)|*.csv|All files (*.*)|*.*'
      CHANGING
        file_table   = lt_file_table
        rc           = lv_rc
      EXCEPTIONS
        OTHERS       = 1.

    IF sy-subrc = 0 AND lv_rc > 0.
      READ TABLE lt_file_table INTO lv_filename INDEX 1.
      IF sy-subrc = 0.
        p_file = lv_filename.
      ENDIF.
    ENDIF.
  ENDIF.

START-OF-SELECTION.

  IF p_file IS INITIAL.
    MESSAGE 'Nenhum arquivo selecionado.' TYPE 'E'.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>gui_upload



exporting
  filename = p_file
  filetype = 'ASC'
changing
  data_tab = lt_data
exceptions
  others   = 1.

IF sy-subrc <> 0.
  MESSAGE 'Erro ao ler o arquivo.' TYPE 'E'.
ENDIF.

* Preencher tabela interna com os dados do CSV
DATA: lv_index TYPE i VALUE 0.

LOOP AT lt_data INTO lv_line.
  ADD 1 TO lv_index.
  IF lv_index = 1.
    CONTINUE. " Pula o cabeçalho
  ENDIF.

  SPLIT lv_line AT ';' INTO TABLE lt_split.

  READ TABLE lt_split INTO lv_field INDEX 1.  ls_cliente-cliente_id       = lv_field.
  READ TABLE lt_split INTO lv_field INDEX 2.  ls_cliente-nome_cliente     = lv_field.
  READ TABLE lt_split INTO lv_field INDEX 3.  ls_cliente-cpf_cnpj         = lv_field.
  READ TABLE lt_split INTO lv_field INDEX 4.  ls_cliente-tipo_cliente     = lv_field.
  READ TABLE lt_split INTO lv_field INDEX 5.  ls_cliente-email            = lv_field.
  READ TABLE lt_split INTO lv_field INDEX 6.  ls_cliente-telefone         = lv_field.
  READ TABLE lt_split INTO lv_field INDEX 7.  ls_cliente-marca_preferida  = lv_field.
  READ TABLE lt_split INTO lv_field INDEX 8.  ls_cliente-modelo_interesse = lv_field.
  READ TABLE lt_split INTO lv_field INDEX 9.  ls_cliente-data_cadastro    = lv_field.
  READ TABLE lt_split INTO lv_field INDEX 10. ls_cliente-ativo            = lv_field.

  APPEND ls_cliente TO lt_clientes.
ENDLOOP.

* Executar batch input para cada cliente
LOOP AT lt_clientes INTO ls_cliente.

  CLEAR lt_bdcdata.

  PERFORM bdc_dynpro      USING 'Z944620INSERIR_CLIENTES' '1000'.
  PERFORM bdc_field       USING 'P_CLI_ID'  ls_cliente-cliente_id.
  PERFORM bdc_field       USING 'P_NOME'    ls_cliente-nome_cliente.
  PERFORM bdc_field       USING 'PCPFCPNJ'  ls_cliente-cpf_cnpj.
  PERFORM bdc_field       USING 'P_TIPO'    ls_cliente-tipo_cliente.
  PERFORM bdc_field       USING 'P_EMAIL'   ls_cliente-email.
  PERFORM bdc_field       USING 'P_TEL'     ls_cliente-telefone.
  PERFORM bdc_field       USING 'P_MARCA'   ls_cliente-marca_preferida.
  PERFORM bdc_field       USING 'P_MODELO'  ls_cliente-modelo_interesse.
  PERFORM bdc_field       USING 'P_DATA'    ls_cliente-data_cadastro.
  PERFORM bdc_field       USING 'P_ATIVO'   ls_cliente-ativo.

* ⚠️ Ajuste aqui o código do botão de salvar conforme sua tela
 PERFORM bdc_field USING 'BDC_OKCODE' 'ONLI'. " ou o código que você viu no botão

  opt-dismode = 'N'. " Modo visual para testes
  CALL TRANSACTION 'ZT944620INS_CLIENTE' USING lt_bdcdata OPTIONS FROM opt.
ENDLOOP.

MESSAGE 'Importação do arquivo concluída com sucesso! Verifique se realmente foi feita a inserção dos dados.' TYPE 'S'.

*---------------------------------------------------------------------*
* Rotinas auxiliares
*---------------------------------------------------------------------*
FORM bdc_dynpro USING program screen.
  CLEAR ls_bdcdata.
  ls_bdcdata-program  = program.
  ls_bdcdata-dynpro   = screen.
  ls_bdcdata-dynbegin = 'X'.
  APPEND ls_bdcdata TO lt_bdcdata.
ENDFORM.

FORM bdc_field USING field value.
  CLEAR ls_bdcdata.
  ls_bdcdata-fnam = field.
  ls_bdcdata-fval = value.
  APPEND ls_bdcdata TO lt_bdcdata.
ENDFORM.
