function _lazygit_log
    if _in_zellij
        _run_cmd_in_zellij_popup fish -c "lg log"
    else
        lg log
    end
end
