{ username, ... }:
{
  wsl = {
    enable = true;
    useWindowsDriver = true;
    defaultUser = username;
    interop.register = true;
  };
}
