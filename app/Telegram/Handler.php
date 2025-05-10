<?php

namespace App\Telegram;

use Defstudio\Telegraph\Handlers\WebhookHandler;

class Handler extends WebhookHandler
{
    public function hello()
    {
        $this -> reply(message: 'Strong Big Penis!');
    }
}
