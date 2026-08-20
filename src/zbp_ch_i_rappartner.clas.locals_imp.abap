CLASS lsc_zch_i_rappartner DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zch_i_rappartner IMPLEMENTATION.

  METHOD adjust_numbers.
    SELECT FROM zch_dmo_partner
    FIELDS MAX( Partner )
    INTO @DATA(ld_max_partner).
    LOOP AT mapped-partner REFERENCE INTO DATA(lr_partner).
      ld_max_partner += 1.
      lr_partner->PartnerNumber = ld_max_partner.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZCH_I_RAPPartner DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Partner RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Partner RESULT result.
    METHODS validateKeyIsFilled FOR VALIDATE ON SAVE
       keys FOR Partner~validateKeyIsFilled.
    METHODS validateCoreData FOR VALIDATE ON SAVE
       keys FOR Partner~validateCoreData.
    METHODS fillCurrency FOR DETERMINE ON MODIFY
       keys FOR Partner~fillCurrency.
    METHODS clearAllEmptyStreets FOR MODIFY
       keys FOR ACTION Partner~clearAllEmptyStreets.

    METHODS fillEmptyStreets FOR MODIFY
       keys FOR ACTION Partner~fillEmptyStreets RESULT result.
    METHODS copyLine FOR MODIFY
       keys FOR ACTION Partner~copyLine.
    METHODS withPopup FOR MODIFY
       keys FOR ACTION Partner~withPopup.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Partner RESULT result.
    METHODS get_global_features FOR GLOBAL FEATURES
      REQUEST requested_features FOR partner RESULT result.

ENDCLASS.

CLASS lhc_ZCH_I_RAPPartner IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validateKeyIsFilled.
*    LOOP AT keys INTO DATA(ls_key) WHERE PartnerNumber IS INITIAL.
*      INSERT VALUE #( PartnerNumber = ls_key-PartnerNumber ) INTO TABLE failed-partner.
*
*      INSERT VALUE #(
*        PartnerNumber = ls_key-PartnerNumber
*        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'PartnerNumber is mandatory' )
*      ) INTO TABLE reported-partner.
*    ENDLOOP.
  ENDMETHOD.

  METHOD validateCoreData.
    READ ENTITIES OF ZCH_I_RAPPartner IN LOCAL MODE
    ENTITY Partner
    FIELDS ( Country PaymentCurrency )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_partner_data)
    FAILED DATA(ls_failed)
    REPORTED DATA(ls_reported).

    LOOP AT lt_partner_data INTO DATA(ls_partner).
      SELECT SINGLE FROM I_Country
        FIELDS Country
        WHERE Country = @ls_partner-Country
        INTO @DATA(ld_found_country).
      IF sy-subrc <> 0.
        INSERT VALUE #( PartnerNumber = ls_partner-PartnerNumber ) INTO TABLE failed-partner.

        INSERT VALUE #(
          PartnerNumber = ls_partner-PartnerNumber
           %msg = new_message_with_text( text = 'Country not found in I_Country' )
           %element-country = if_abap_behv=>mk-on
        ) INTO TABLE reported-partner.
      ENDIF.

      SELECT SINGLE FROM I_Currency
        FIELDS Currency
        WHERE Currency = @ls_partner-PaymentCurrency
        INTO @DATA(ld_found_currency).
      IF sy-subrc <> 0.
        INSERT VALUE #( PartnerNumber = ls_partner-PartnerNumber ) INTO TABLE failed-partner.

        INSERT VALUE #(
          PartnerNumber = ls_partner-PartnerNumber
           %msg = new_message_with_text( text = 'Currency not found in I_Currency' )
           %element-paymentcurrency = if_abap_behv=>mk-on
        ) INTO TABLE reported-partner.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD fillCurrency.
    READ ENTITIES OF ZCH_I_RAPPartner IN LOCAL MODE
    ENTITY Partner
    FIELDS ( PaymentCurrency )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_partner_data).

    LOOP AT lt_partner_data INTO DATA(ls_partner) WHERE PaymentCurrency IS INITIAL.
      MODIFY ENTITIES OF ZCH_I_RAPPartner IN LOCAL MODE
        ENTITY Partner
        UPDATE FIELDS ( PaymentCurrency )
        WITH VALUE #( ( %tky = ls_partner-%tky PaymentCurrency = 'EUR' %control-paymentcurrency = if_abap_behv=>mk-on ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD clearAllEmptyStreets.
    SELECT FROM zch_dmo_partner
        FIELDS partner, street
        WHERE street = 'EMPTY'
        INTO TABLE @DATA(lt_partner_data).

    LOOP AT lt_partner_data INTO DATA(ls_partner).
      MODIFY ENTITIES OF ZCH_I_RAPPartner IN LOCAL MODE
        ENTITY Partner
        UPDATE FIELDS ( Street )
        WITH VALUE #( ( PartnerNumber = ls_partner-partner Street = '' %control-Street = if_abap_behv=>mk-on ) ).
    ENDLOOP.

    INSERT VALUE #(
      %msg = new_message_with_text( text = |{ lines( lt_partner_data ) } records changed|
      severity = if_abap_behv_message=>severity-success )
    ) INTO TABLE reported-partner.
  ENDMETHOD.


  METHOD fillEmptyStreets.
    READ ENTITIES OF ZCH_I_RAPPartner IN LOCAL MODE
      ENTITY Partner
      FIELDS ( Street )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partner_data).

    LOOP AT lt_partner_data INTO DATA(ls_partner) WHERE Street IS INITIAL.
      MODIFY ENTITIES OF ZCH_I_RAPPartner IN LOCAL MODE
        ENTITY Partner
        UPDATE FIELDS ( Street )
        WITH VALUE #( ( %tky = ls_partner-%tky Street = 'EMPTY' %control-Street = if_abap_behv=>mk-on ) ).

      INSERT VALUE #( %tky = ls_partner-%tky %param = ls_partner ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.


  METHOD copyLine.
    DATA:
      lt_creation TYPE TABLE FOR CREATE ZCH_I_RAPPartner.

    READ ENTITIES OF ZCH_I_RAPPartner IN LOCAL MODE
      ENTITY Partner ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_partner_data).

    SELECT FROM zch_dmo_partner
      FIELDS MAX( partner )
      INTO @DATA(ld_number).

    LOOP AT lt_partner_data INTO DATA(ls_partner).
      ld_number += 1.
      ls_partner-PartnerNumber = ld_number.
      ls_partner-PartnerName &&= | copy|.

      INSERT VALUE #( %cid = keys[ sy-tabix ]-%cid ) INTO TABLE lt_creation REFERENCE INTO DATA(lr_create).
      lr_create->* = CORRESPONDING #( ls_partner ).
      lr_create->%control-PartnerNumber = if_abap_behv=>mk-on.
      lr_create->%control-PartnerName = if_abap_behv=>mk-on.
      lr_create->%control-Street = if_abap_behv=>mk-on.
      lr_create->%control-City = if_abap_behv=>mk-on.
      lr_create->%control-Country = if_abap_behv=>mk-on.
      lr_create->%control-PaymentCurrency = if_abap_behv=>mk-on.
    ENDLOOP.

    MODIFY ENTITIES OF ZCH_I_RAPPartner IN LOCAL MODE
      ENTITY Partner CREATE FROM lt_creation
      FAILED DATA(ls_failed)
      MAPPED DATA(ls_mapped)
      REPORTED DATA(ls_reported).

    mapped-partner = ls_mapped-partner.
  ENDMETHOD.

  METHOD withPopup.
    TRY.
        DATA(ls_key) = keys[ 1 ].
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    CASE ls_key-%param-MessageType.
      WHEN 1.
        INSERT VALUE #(
         %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success text = 'Dummy Message' ) )
        INTO TABLE reported-partner.
      WHEN 2.
        INSERT VALUE #(
        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-information text = 'Dummy Message'  ) ) INTO TABLE reported-partner.
      WHEN 3.
        INSERT VALUE #(
        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-warning text = 'Dummy Message' ) ) INTO TABLE reported-partner.
      WHEN 4.
        INSERT VALUE #(
        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Dummy Message' ) ) INTO TABLE reported-partner.
      WHEN 5.
        INSERT VALUE #(
           %msg = new_message_with_text( severity = if_abap_behv_message=>severity-none text = 'Dummy Message' ) ) INTO TABLE reported-partner.
      WHEN 6.
        reported-partner = VALUE #( ( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success text = 'Dummy Message' ) )
                                   ( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-information text = 'Dummy Message'  ) )

                                 ).
      WHEN 7.
        reported-partner = VALUE #(
    ( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success text = 'Dummy message' ) )
    ( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Dummy message' ) )
    ( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-warning text = 'Dummy message' ) )
    ( %msg = new_message_with_text( severity = if_abap_behv_message=>severity-information text = 'Dummy message' ) )

                            ).
    ENDCASE.
  ENDMETHOD.

  METHOD get_instance_features.
    IF requested_features-%action-fillEmptyStreets = if_abap_behv=>mk-on.
        READ ENTITIES OF zch_I_RAPPartner IN LOCAL MODE
        ENTITY Partner
        FIELDS ( Street )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_partners).

        LOOP AT lt_partners INTO DATA(ls_partner) WHERE street IS NOT INITIAL.
            INSERT VALUE #( partnernumber = ls_partner-partnernumber
                            %action-fillemptystreets = if_abap_behv=>mk-on )
                            INTO TABLE result.
        ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD get_global_features.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).
    IF requested_features-%delete = if_abap_behv=>mk-on.
        DATA(ld_deactivate) = COND #(
            WHEN lv_user = 'CB9980006630'
             THEN if_abap_behv=>mk-off
            ELSE
              if_abap_behv=>mk-on
         ).

         result-%delete = ld_deactivate.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
