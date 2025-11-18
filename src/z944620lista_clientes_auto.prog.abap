REPORT Z944620LISTA_CLIENTES_AUTO.

TABLES : z944620cli_auto.

DATA : it_z944620cli_auto TYPE STANDARD TABLE OF z944620cli_auto,
       wa_z944620cli_auto TYPE z944620cli_auto.

DATA : lv_cab TYPE c LENGTH 1.

SELECTION-SCREEN BEGIN OF BLOCK b_janela WITH FRAME TITLE text-001.
  SELECT-OPTIONS : s_codigo FOR z944620cli_auto-cliente_id,
                   s_marca FOR z944620cli_auto-marca_preferida,
                   s_data FOR z944620cli_auto-data_cadastro,
                   s_ativo FOR z944620cli_auto-ativo.
SELECTION-SCREEN END OF BLOCK b_janela.

START-OF-SELECTION.
  SELECT * FROM z944620cli_auto
    INTO TABLE it_z944620cli_auto
    WHERE cliente_id IN s_codigo
    AND   marca_preferida IN s_marca
    AND   data_cadastro IN s_data
    AND   ativo IN s_ativo
    ORDER BY cliente_id.
END-OF-SELECTION.

CLEAR : lv_cab.

LOOP AT it_z944620cli_auto INTO wa_z944620cli_auto.
    IF lv_cab = ' '.
      WRITE : /05  'Codigo',
               16  'Nome Cliente',
               50  'Email',
               80  'Marca Preferida',
               100 'Modelo de Interesse',
               125 'Cadastro',
               136 'Ativo'.
      lv_cab = 'X'.

      ENDIF.
      WRITE : /05  wa_z944620cli_auto-cliente_id,
               16  wa_z944620cli_auto-nome_cliente,
               50  wa_z944620cli_auto-email,
               80  wa_z944620cli_auto-marca_preferida,
               100 wa_z944620cli_auto-modelo_interesse,
               125 wa_z944620cli_auto-data_cadastro USING EDIT MASK '__/__/____',
               136 wa_z944620cli_auto-ativo.
  ENDLOOP.
