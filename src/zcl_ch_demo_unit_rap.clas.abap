"! @testing ZCH_I_RAPPartner
CLASS zcl_ch_demo_unit_rap DEFINITION  PUBLIC  FINAL  CREATE PUBLIC
 FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: go_environment TYPE ref to if_cds_test_environment.

    CLASS-METHODS:
        class_setup RAISING cx_static_check,
        class_teardown.

    METHODS: create_new_entry FOR TESTING,
      fill_empty_streets      FOR TESTING,
      clear_empty_streets     FOR TESTING.
ENDCLASS.



CLASS zcl_ch_demo_unit_rap IMPLEMENTATION.
  METHOD clear_empty_streets.
    DATA: lt_clear_streets TYPE TABLE FOR ACTION IMPORT zch_I_RAPPartner~clearAllEmptyStreets.

    INSERT INITIAL LINE INTO TABLE lt_clear_streets.
    lt_clear_streets[ 1 ]-%cid = 'new_test_100'.

    MODIFY ENTITIES OF zch_I_RAPPartner
    ENTITY Partner
    EXECUTE clearAllEmptyStreets FROM lt_clear_streets
    MAPPED DATA(ls_mapped)
    REPORTED DATA(ls_reported)
    FAILED DATA(ls_failed).

    COMMIT ENTITIES
    RESPONSE OF zch_I_RAPPartner
     REPORTED DATA(ls_commit_reported)
     FAILED DATA(ls_commit_failed).

    SELECT SINGLE FROM zch_dmo_partner
    FIELDS Partner, Street
    WHERE Street = 'EMPTY'
    INTO @DATA(ls_partner_found).

    cl_abap_unit_assert=>assert_subrc( exp = '4' ).

  ENDMETHOD.

  METHOD create_new_entry.
    DATA: lt_new_partner TYPE TABLE FOR CREATE zch_I_RAPPartner.

    lt_new_partner[] = VALUE #(
       (
        %cid = 'new_test_001'
        PartnerName = 'Do it Yourself'
        Street = 'Waterloo Street 13'
        City = 'London'
        Country = 'GB'
        PaymentCurrency = 'GBP'
        %control-PartnerName = if_abap_behv=>mk-on
        %control-Street = if_abap_behv=>mk-on
        %Control-City = if_abap_behv=>mk-on
        %Control-Country = if_abap_behv=>mk-on
        %Control-PaymentCurrency = if_abap_behv=>mk-on ) ).

    MODIFY ENTITIES OF zch_I_RAPPartner
    ENTITY Partner
    CREATE FROM lt_new_partner
    MAPPED DATA(ls_mapped).

    COMMIT ENTITIES
     RESPONSE OF zch_I_RAPPartner
     REPORTED DATA(ls_commit_reported)
     FAILED DATA(ls_commit_failed).

    cl_abap_unit_assert=>assert_initial( ls_commit_reported-partner ).
    cl_abap_unit_assert=>assert_initial( ls_commit_failed-partner ).

    SELECT SINGLE FROM zch_dmo_partner
    FIELDS partner,name
    WHERE name = 'Do it Yourself'
    INTO @DATA(ls_partner_found).

    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD fill_empty_streets.
    DATA: lt_fill_streets TYPE TABLE FOR ACTION IMPORT zch_I_RAPPartner~fillEmptyStreets.

    lt_fill_streets = VALUE #(
    (  PartnerNumber = '2000000001' ) ).

    MODIFY ENTITIES OF ZCH_I_RAPPartner
    ENTITY Partner
    EXECUTE fillEmptyStreets FROM lt_fill_streets
    MAPPED DATA(ls_mapped)
    REPORTED DATA(ls_reported)
    FAILED DATA(ls_failed).

    COMMIT ENTITIES
     RESPONSE OF zch_I_RAPPartner
     REPORTED DATA(ls_commit_resported)
     FAILED DATA(ls_commit_failed).

    SELECT SINGLE FROM zch_dmo_partner
    FIELDS partner, street
    WHERE partner = '2000000001'
    INTO @DATA(ls_partner_found).

    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( act = ls_partner_found-street exp = 'EMPTY' ).
  ENDMETHOD.

  METHOD class_setup.
    DATA: lt_partners TYPE STANDARD TABLE OF zch_dmo_partner WITH empty key.

    go_environment = cl_cds_test_environment=>create( i_for_entity = 'ZCH_I_RAPPARTNER'
                                                      i_dependency_list = VALUE #( ( name = 'ZCH_DMO_PARTNER' type = 'TABLE' ) ) ).

    lt_partners = VALUE #(
    ( partner = '2000000001' name = 'Las Vegas Corp' country = 'US' payment_currency = 'USD' )
    ( partner = '2000000002' name = 'Gorillas' street = 'Main street 10' country = 'DE' payment_currency = 'EUR' )
    ( partner = '2000000003' name = 'Tomato Inc' street = 'EMPTY' country = 'AU' payment_currency = 'AUD' ) ).

    go_environment->insert_test_data( lt_partners ).
    go_environment->enable_double_redirection(  ).

  ENDMETHOD.

  METHOD class_teardown.
    go_environment->destroy(  ).
  ENDMETHOD.

ENDCLASS.
