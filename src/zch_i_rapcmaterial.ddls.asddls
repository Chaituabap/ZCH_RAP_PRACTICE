@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Material'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCH_I_RAPCMaterial
  as select from zch_dmo_material
{
  key material       as Material,
      name           as MaterialName,
      description    as MaterialDescription,
      @Semantics.quantity.unitOfMeasure: 'StockUnit'
      stock          as Stock,
      stock_unit     as StockUnit,
      @Semantics.amount.currencyCode: 'Currency'
      price_per_unit as PricePerUnit,
      currency       as Currency
}
