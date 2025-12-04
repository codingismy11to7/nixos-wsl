function _lazygit_status
    if _in_zellij
        _run_cmd_in_zellij_popup fish -c "lg status"
    else
        lg status
    end
end
