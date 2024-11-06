




`include "./error_reconcilation_parameter.v"

module shuffle_invshuffle (
    input [`CASCADE_KEY_LENGTH-1:0] original_key,

    output [`CASCADE_KEY_LENGTH-1:0] shuffle_key_2,
    output [`CASCADE_KEY_LENGTH-1:0] shuffle_key_3,
    output [`CASCADE_KEY_LENGTH-1:0] shuffle_key_4,

    output [`CASCADE_KEY_LENGTH-1:0] inv_shuffle_key_2,
    output [`CASCADE_KEY_LENGTH-1:0] inv_shuffle_key_3,
    output [`CASCADE_KEY_LENGTH-1:0] inv_shuffle_key_4

);




    shuffle_2 shuffle_set_2(
        .key_original(original_key),
        .key_shuffle(shuffle_key_2)
    );
    shuffle_3 shuffle_set_3(
        .key_original(original_key),
        .key_shuffle(shuffle_key_3)
    );
    shuffle_4 shuffle_set_4(
        .key_original(original_key),
        .key_shuffle(shuffle_key_4)
    );


    inv_shuffle_2 invshuffle_set_2(
        .key_original(inv_shuffle_key_2),
        .key_shuffle(original_key)
    );
    inv_shuffle_3 invshuffle_set_3(
        .key_original(inv_shuffle_key_3),
        .key_shuffle(original_key)
    );
    inv_shuffle_4 invshuffle_set_4(
        .key_original(inv_shuffle_key_4),
        .key_shuffle(original_key)
    );



endmodule