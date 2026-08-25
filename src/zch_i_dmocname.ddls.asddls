@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Cname table'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCH_I_DmoCname
  as select from zch_dmo_cname
{
  key name        as CompanyName,
      branch      as Branch,
      description as CompanyDescription
}
