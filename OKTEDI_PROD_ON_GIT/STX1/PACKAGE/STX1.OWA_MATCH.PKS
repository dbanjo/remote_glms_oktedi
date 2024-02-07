CREATE OR REPLACE package STX1.owa_match

as

    empty_vc_arr owa_util.vc_arr;

    function match_pattern
    (
        p_string            in varchar2,
        p_simple_pattern    in owa_util.vc_arr default empty_vc_arr,
        p_complex_pattern   in owa_util.vc_arr default empty_vc_arr,
        p_use_special_chars in boolean         default true
    )
    return boolean;

end owa_match;

/
