(function () {
    var search_users_timeout;

    var search_users = function (str) {
        var params = {'user_email_like':str};
        var $results = $('#search_users_result');
        $results.html('');
        $.getJSON(simple_forum.user_search_path, params, function (json) {
            $.each(json, function (key, val) {
                var $item = $('<li>' + val + ' <a href="#" class="add-moderator" data-user_id="' + key + '" data-user_email="' + val + '">[' + simple_forum.translations['add_moderator'] + ']</a></li>');
                $results.append($item);
            });
        });
    };

    $(function () {
        $('#search_users_input').keyup(function () {
            var $input = $(this);
            if (search_users_timeout) clearTimeout(search_users_timeout);
            search_users_timeout = setTimeout(function () {
                search_users($input.val());
            }, 300);
        });

        $(document).on('click', 'a.add-moderator', function () {
            var $this = $(this),
                user_id = $this.data('user_id'),
                user_email = $this.data('user_email');
            var html = simple_forum.moderator_template.replace(/temp_user_id/g, user_id).replace(/temp_user_email/g, user_email);
            $('#moderators').append(html);
            return false;
        });

        $(document).on('click', 'a.remove-moderator', function () {
            var $this = $(this);
            $this.closest('li').remove();
            return false;
        });
    });
})();