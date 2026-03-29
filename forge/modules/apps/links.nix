{
  lib,
  ...
}:
let
  link-submodule = lib.types.submodule (
    { name, ... }:
    {
      options = {
        text = lib.mkOption {
          description = "link text";
          type = lib.types.str;
          default = name;
        };
        description = lib.mkOption {
          description = "long-form description of the linked resource";
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        url = lib.mkOption {
          # basic check for the URI syntax
          # https://www.rfc-editor.org/rfc/rfc3986#section-3.1
          type = lib.types.strMatching "[a-zA-Z][a-zA-Z0-9+\-.]*://[^ \t\n]+";
          description = "URL of the linked resource";
        };
      };
    }
  );

  # - `links.website = "https://foobar.com";`
  # - `links.website = { text = "Homepage"; url = "https://foobar.com"; };`
  link = lib.types.coercedTo lib.types.str (url: { inherit url; }) link-submodule;
in
{
  options = {
    website = lib.mkOption {
      type = lib.types.nullOr link;
      description = "Project website.";
      default = null;
    };
    docs = lib.mkOption {
      type = lib.types.nullOr link;
      description = "Project Documentation.";
      default = null;
    };
  };
}
