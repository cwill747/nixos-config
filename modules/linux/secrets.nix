{ config, inputs, ... }:

let user = "cameron"; in
{
  age = {
    identityPaths = [ "/home/${user}/.ssh/nixkey" ];
    secrets = {
      tx02-regular-ttf = {
        path = "/home/${user}/.local/share/fonts/TX-02-Regular.ttf";
        file = "${inputs.secrets}/fonts/TX-02-Regular.ttf.age";
        mode = "0644";
        owner = "${user}";
      };
      tx02-regular-woff2 = {
        path = "/home/${user}/.local/share/fonts/TX-02-Regular.woff2";
        file = "${inputs.secrets}/fonts/TX-02-Regular.woff2.age";
        mode = "0644";
        owner = "${user}";
      };
      tx02-bold-ttf = {
        path = "/home/${user}/.local/share/fonts/TX-02-Bold.ttf";
        file = "${inputs.secrets}/fonts/TX-02-Bold.ttf.age";
        mode = "0644";
        owner = "${user}";
      };
      tx02-bold-oblique-ttf = {
        path = "/home/${user}/.local/share/fonts/TX-02-Bold-Oblique.ttf";
        file = "${inputs.secrets}/fonts/TX-02-Bold-Oblique.ttf.age";
        mode = "0644";
        owner = "${user}";
      };
      tx02-bold-condensed-ttf = {
        path = "/home/${user}/.local/share/fonts/TX-02-Bold-Condensed.ttf";
        file = "${inputs.secrets}/fonts/TX-02-Bold-Condensed.ttf.age";
        mode = "0644";
        owner = "${user}";
      };
      tx02-bold-condensed-oblique-ttf = {
        path = "/home/${user}/.local/share/fonts/TX-02-Bold-Condensed-Oblique.ttf";
        file = "${inputs.secrets}/fonts/TX-02-Bold-Condensed-Oblique.ttf.age";
        mode = "0644";
        owner = "${user}";
      };
      tx02-condensed-ttf = {
        path = "/home/${user}/.local/share/fonts/TX-02-Condensed.ttf";
        file = "${inputs.secrets}/fonts/TX-02-Condensed.ttf.age";
        mode = "0644";
        owner = "${user}";
      };
      tx02-condensed-oblique-ttf = {
        path = "/home/${user}/.local/share/fonts/TX-02-Condensed-Oblique.ttf";
        file = "${inputs.secrets}/fonts/TX-02-Condensed-Oblique.ttf.age";
        mode = "0644";
        owner = "${user}";
      };
      tx02-oblique-ttf = {
        path = "/home/${user}/.local/share/fonts/TX-02-Oblique.ttf";
        file = "${inputs.secrets}/fonts/TX-02-Oblique.ttf.age";
        mode = "0644";
        owner = "${user}";
      };
    };
  };
}