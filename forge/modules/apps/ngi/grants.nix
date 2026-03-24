/**
  Funding that software authors receive from NLnet to support various software projects.
  Each subgrant comes from a fund, which is in turn bound to a grant agreement with the European commission.

  We track: `Commons`, `Core`, `Entrust` and `Review`.
  While the first three are current fund themes, `Review` encompasses all non-current NGI funds (e.g. Assure, Discovery, PET, ...).

  See [NLnet - Thematics Funds](https://nlnet.nl/themes/) for more information.
*/
{
  lib,
  ...
}:
{
  options =
    lib.genAttrs
      [
        "Commons"
        "Core"
        "Entrust"
        "Review"
      ]
      (
        name:
        lib.mkOption {
          description = "subgrants under the ${name} fund";
          type = lib.types.listOf lib.types.str;
          default = [ ];
        }
      );
}
