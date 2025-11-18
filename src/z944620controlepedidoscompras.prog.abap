REPORT z944620controlepedidoscompras NO STANDARD PAGE HEADING MESSAGE-ID zcontrolepedidos.

TABLES : ekko, ekpo, usr01. " Declara tabelas do dicionário para acesso direto aos campos

" Define um tipo interno para armazenar dados do relatório
TYPES : BEGIN OF ty_pedidos,
          ebeln TYPE ekko-ebeln,    " Número do documento de compras
          ebelp TYPE ekpo-ebelp,    " Item do documento
          bukrs TYPE ekko-bukrs,    " Código da empresa
          matnr TYPE ekpo-matnr,    " Código do material
          werks TYPE ekpo-werks,    " Centro
          aedat TYPE ekko-aedat,    " Data de criação do pedido
          ernam TYPE ekko-ernam,    " Usuário criador do pedido
        END OF ty_pedidos.

" Declara tabela interna e work area para armazenar os pedidos
DATA : it_pedidos TYPE TABLE OF ty_pedidos,
       wa_pedidos TYPE ty_pedidos.

DATA : wa_tvarvc TYPE RANGE OF sy-uname,
       it_tvarvc TYPE STANDARD TABLE OF tvarvc.

" Objetos para manipulação do ALV OO
DATA : go_alv       TYPE REF TO cl_salv_table,          " Objeto principal do ALV
       lr_functions TYPE REF TO cl_salv_functions_list, " Funções do ALV (botões)
       gr_display   TYPE REF TO cl_salv_display_settings, " Configurações de exibição
       lo_header    TYPE REF TO cl_salv_form_layout_grid, " Layout do cabeçalho
       lo_h_flow    TYPE REF TO cl_salv_form_layout_flow. " Fluxo para posicionar textos

" Variáveis para armazenar usuário logado e nome completo
DATA : lv_uname TYPE sy-uname,          " Código do usuário logado
       lv_name  TYPE adrp-name_text.    " Nome completo do usuário

" Tela de seleção - Bloco 1
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_ebeln FOR wa_pedidos-ebeln OBLIGATORY, " Filtro para número do pedido
                  s_ebelp FOR wa_pedidos-ebelp,            " Filtro para item do pedido
                  s_aedat FOR wa_pedidos-aedat.            " Filtro para data do pedido
  PARAMETERS : p_ernam TYPE ty_pedidos-ernam.              " Parâmetro opcional para usuário criador
SELECTION-SCREEN END OF BLOCK b1.

" Tela de seleção - Bloco 2
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS : p_alv    RADIOBUTTON GROUP grp1 DEFAULT 'X', " Opção para saída ALV
               p_writer RADIOBUTTON GROUP grp1.             " Opção para saída WRITE
SELECTION-SCREEN END OF BLOCK b2.

" Início do processamento

START-OF-SELECTION.
  PERFORM seleciona_dados.

  IF sy-subrc = 0.
    IF NOT it_tvarvc IS INITIAL.
      READ TABLE it_tvarvc WITH KEY low = sy-uname TRANSPORTING NO FIELDS.

      IF sy-subrc = 0. "Encontrou o usuário
        IF p_alv = 'X'.
          PERFORM relatorio_alv.    " Exibe ALV
        ELSEIF p_writer = 'X'.
          PERFORM relatorio_writer. " Exibe saída com WRITE
        ENDIF.
      ELSE.
        MESSAGE s000 DISPLAY LIKE 'E'.
      ENDIF.
    ELSE.
      MESSAGE s000 DISPLAY LIKE 'E'.
    ENDIF.
  ELSE.
    MESSAGE : s001 DISPLAY LIKE 'E'.
  ENDIF.

" Rotina para seleção de dados
FORM seleciona_dados.
  "Seleciona os valores da TVARV
  SELECT * FROM tvarvc
    INTO TABLE it_tvarvc
    WHERE name = 'Z_USUARIOS_PEDIDOS'.

  " Captura código do usuário logado
  lv_uname = sy-uname.

  " Busca nome completo do usuário na ADRP usando persnumber da USR21
  SELECT SINGLE name_text
    INTO lv_name
    FROM adrp AS a
    INNER JOIN usr21 AS u
      ON a~persnumber = u~persnumber
    WHERE u~bname = lv_uname.

  " Busca pedidos conforme filtros da tela
  SELECT k~ebeln, p~ebelp, k~bukrs, p~matnr, p~werks, k~aedat, k~ernam
  INTO CORRESPONDING FIELDS OF TABLE @it_pedidos
  FROM ekko AS k
  INNER JOIN ekpo AS p
    ON k~ebeln = p~ebeln
  WHERE k~ebeln IN @s_ebeln
    AND p~ebelp IN @s_ebelp
    AND k~aedat IN @s_aedat.
ENDFORM.

" Rotina para exibir ALV
FORM relatorio_alv.
  DESCRIBE TABLE it_pedidos LINES DATA(v_total_lines). " Conta linhas da tabela interna

  TRY.
      cl_salv_table=>factory( " Cria objeto ALV
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = it_pedidos[] ).
    CATCH cx_salv_msg. " Captura erro caso ocorra
  ENDTRY.

  " Habilita botões de função no ALV
  lr_functions = go_alv->get_functions( ).
  lr_functions->set_all( 'X' ).

  " Ativa padrão zebra no ALV
  gr_display = go_alv->get_display_settings( ).
  gr_display->set_striped_pattern( cl_salv_display_settings=>true ).

  " Cria objeto para cabeçalho
  CREATE OBJECT lo_header.

  " Linha 1: Usuário
  lo_h_flow = lo_header->create_flow( row = 1  column = 1 ).
  lo_h_flow->create_text( text = TEXT-003 ).
  lo_h_flow = lo_header->create_flow( row = 1  column = 2 ).
  lo_h_flow->create_text( text = lv_name ).

  " Linha 2: Data e hora
  lo_h_flow = lo_header->create_flow( row = 2  column = 1 ).
  lo_h_flow->create_text( text = TEXT-004 ).
  lo_h_flow = lo_header->create_flow( row = 2  column = 2 ).
  lo_h_flow->create_text( text = sy-datum ).

  lo_h_flow = lo_header->create_flow( row = 2  column = 3 ).
  lo_h_flow->create_text( text = TEXT-005 ).
  lo_h_flow = lo_header->create_flow( row = 2  column = 4 ).
  lo_h_flow->create_text( text = sy-uzeit ).

  " Linha 3: Título do relatório
  lo_h_flow = lo_header->create_flow( row = 3  column = 1 ).
  lo_h_flow->create_text( text = TEXT-006 ).

  " Define cabeçalho para exibição e impressão
  go_alv->set_top_of_list( lo_header ).
  go_alv->set_top_of_list_print( lo_header ).

  " Exibe ALV na tela
  go_alv->display( ).
ENDFORM.

" Rotina para saída com WRITE
FORM relatorio_writer.
  " Informações do usuário, data e hora
  WRITE: / |{ TEXT-003 } { lv_name }|,
         / |{ TEXT-004 } { sy-datum+6(2) }.{ sy-datum+4(2) }.{ sy-datum(4) } { TEXT-005 } { sy-uzeit(2) }:{ sy-uzeit+2(2) }:{ sy-uzeit+4(2) }|,
         / |{ TEXT-006 }|,
         / .

  " Cabeçalho das colunas com borda
  WRITE: / '***********************************************************************************************************************'.
  WRITE: / |* { TEXT-007 }|, '|', |{ TEXT-008 }|, '|', |{ TEXT-009 }|, '|', |{ TEXT-010 }            |, '|', |{ TEXT-011 }|, '|', |{ TEXT-012 }|, '|', |{ TEXT-013 }  *|.
  WRITE: / '***********************************************************************************************************************'.

  " Loop para exibir dados linha a linha com borda
  LOOP AT it_pedidos INTO wa_pedidos.
    WRITE: / |* { wa_pedidos-ebeln WIDTH = 20 }|,
             '|',|{ wa_pedidos-ebelp WIDTH = 17 }|,
             '|',|{ wa_pedidos-bukrs WIDTH = 7 }|,
             '|',|{ wa_pedidos-matnr WIDTH = 20 }|,
             '|',|{ wa_pedidos-werks WIDTH = 6 }|,
             '|',|{ wa_pedidos-aedat WIDTH = 15 }|,
             '|',|{ wa_pedidos-ernam WIDTH = 13 }*|.
  ENDLOOP.

  WRITE: / '***********************************************************************************************************************'.
ENDFORM.
