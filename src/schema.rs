table! {
    notification_data (id) {
        id -> Integer,
        sender -> Text,
        title -> Text,
        body -> Text,
        created_at -> Timestamp,
        updated_at -> Timestamp,
        unread -> Bool,
    }
}
