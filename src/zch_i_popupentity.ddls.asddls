@EndUserText.label: 'Entity for popup'
define abstract entity ZCH_I_PopupEntity
{
  @Consumption.valueHelpDefinition: [{ entity :{ name: 'ZCH_C_COUNTRYVH', element: 'Country'} }]
  @EndUserText.label: 'Search Country'
  SearchCountry : land1;
  @EndUserText.label: 'New Date'
  NewDate       : abap.dats;
  @EndUserText.label: 'Message Type'
  MessageType   : abap.int4;
  @EndUserText.label: 'Update Data'
  FlagUpdate    : abap.char(1);
  @EndUserText.label: 'Show Messages'
  FlagMessage   : abap_boolean;

}
