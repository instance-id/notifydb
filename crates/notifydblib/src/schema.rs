diesel::table! {
    notification_data (id) {
        id -> Integer,
        sender -> Text,
        title -> Nullable<Text>,
        body -> Nullable<Text>,
        actions -> Nullable<Text>,
        hints -> Nullable<Text>,
        icon -> Nullable<Text>,
        timeout -> Integer,
        unread -> Bool,
        archived -> Bool,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}

diesel::table! {
    settings_data (id) {
        id -> Integer,
        application -> Text,
        settings_json -> Text,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}

diesel::allow_tables_to_appear_in_same_query!(notification_data, settings_data,);
