defmodule Checker.Notify do
  import Swoosh.Email

  # @you "your-email@gmail.com"

  # @slack "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"

  # https://github.com/regality/sms-address
  # @sms "0000000000@tmomail.net"
  # @sms2 "0000000000@vzwpix.com"

  def error(msg) do
    if should_send() do
      # slack(@slack, msg)
    end
  end

  def all(name, url) do
    if should_send() do
      msg = "Playstation 5 available at #{name}! #{url}"
      # slack(@slack, msg)
      token = Checker.GmailAuth.get_access_token()

      if token do
        # text(@sms, msg, token)
        # text(@sms2, msg, token)
      else
        error("PS5 availabe at #{name} but couldn't send texts!!!")
      end
    end
  end

  defp slack(hook, msg) do
    HTTPoison.post(hook, Jason.encode!(%{text: msg}))
  end

  defp text(to, msg, token) do
    new()
    |> to(to)
    |> from(@you)
    |> text_body(msg)
    |> html_body(msg)
    |> Checker.Mailer.deliver(access_token: token)
  end

  # uncomment the following to disable all messages
  # defp should_send(), do: false

  # only send messages between 7am and 11pm mountain time
  defp should_send() do
    {_, {hour, _, _}} = :calendar.universal_time()
    rem(hour + 24 - 6, 24) in 7..23
  end
end
