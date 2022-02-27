table! {
    notification_data (id) {
        id -> Integer,
        sender -> Text,
        title -> Text,
        body -> Text,
        created_at -> Timestamp,
        updated_at -> Timestamp,
        unread -> Bool,
        archived -> Bool,
    }
}

table! {
    settings_data (id) {
        id -> Integer,
        application -> Text,
        settings_json -> Text,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}

allow_tables_to_appear_in_same_query!(
    notification_data,
    settings_data,
);
