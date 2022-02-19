diesel::table! {
    notification_data (id) {
        id -> Integer,
        sender -> Text,
        title -> Nullable<Text>,
        body -> Nullable<Text>,
        unread -> Bool,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}
