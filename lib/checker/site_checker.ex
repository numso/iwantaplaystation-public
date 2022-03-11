defmodule Checker.SiteChecker do
  use GenServer

  @interval :timer.minutes(2)

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  @impl true
  def init(name) do
    IO.puts("Starting checker for #{name}")
    Process.send_after(self(), :check, :timer.seconds(5))
    {:ok, name}
  end

  @impl true
  def handle_info(:check, name) do
    Process.send_after(self(), :check, @interval)
    {url, headers, texts} = apply(__MODULE__, name, [])

    case HTTPoison.get(url, headers) do
      {:ok, resp} ->
        resp
        |> Map.get(:body)
        |> String.downcase()
        |> String.contains?(texts)
        |> case do
          true ->
            IO.puts("THEY ARE IN STOCK #{url}")
            Checker.Notify.all(name, url)

          _ ->
            nil
        end

      err ->
        IO.inspect(err)
        Checker.Notify.error("The #{name} checker busted")
    end

    {:noreply, name}
  end

  @amazon_url "https://www.amazon.com/PlayStation-5-Console/dp/B08FC5L3RG"
  @walmart_url "https://www.walmart.com/ip/Sony-PlayStation-5-Video-Game-Console/994712501"
  @target_url "https://www.target.com/p/playstation-5-console/-/A-81114595"
  @gamestop_url "https://www.gamestop.com/video-games/playstation-5/consoles/products/playstation-5/11108140.html"
  @bestbuy_url "https://www.bestbuy.com/site/sony-playstation-5-console/6426149.p?skuId=6426149"
  @smiths_url "https://www.smithsfoodanddrug.com/p/playstation-5-console-1-per-customer-/0071171954102"

  def amazon() do
    {@amazon_url, [], "add to cart"}
  end

  def walmart() do
    {@walmart_url, [], "prod-productcta"}
  end

  def target() do
    {@target_url, [], ["ship to store", "ship it", "deliver it", "pick it up"]}
  end

  def gamestop() do
    headers = [
      accept: "text/html",
      "user-agent":
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36 Edg/91.0.864.41"
    ]

    {@gamestop_url, headers, "add to cart</button>"}
  end

  def bestbuy() do
    headers = [
      "user-agent": "vscode-restclient",
      accept: "text/html",
      "accept-encoding": "gzip, deflate",
      cookie:
        "SID=1d6d010c-893c-4dd2-a395-fe4688e7ee70; oid=199767527; vt=ecea4faa-eb03-11eb-bc3e-068883cb7b07; _abck=933AA88D9A56974BFDFD53EBF8A44502~-1~YAAQtSzorAjGadN6AQAAa8ky1AY6tEKOe3ZVirWPr7k1lESB8IpUoRh7gol8U6zvuaiETB/YF+1V7S8HpdgaakaB7O26rJ+0tkR1Zsb8PuWO3/mFA0XDHvBEREUdIQTGY8KnqN4tTe4++MKW2Woh0TxurB/ieIM7Q7Rp2yJ6V8YbDEn2C2EAHZIr8sTotEJiOm3xAp4VDVpM3P2QaFaUCPk5/mekzEKyx8Xe8PrjzTLCHv889oOqutM0Tc3h8aS3Z+BgH167zzvTharcypo+05FKZj2i4/VueOKe7ZHtUtyAvyIen3Trf2GRoue3NQUTMVEX8G21Fve6XRBl5avDj15UzTskg5aoRHZ2u5y/+68i1BuwtqZz5ZMgjh9D~-1~-1~-1; CTT=8c4fdde773457af35b0a56d4fcfb04e4; physical_dma=770; customerZipCode=84647|N; ltc=%20; bm_sz=4B0121CADAE61F714C33FFC52A502E59~YAAQtSzorAnGadN6AQAAa8ky1AzzpuN8eFAPZHfA36Q4slY3gs7fsPDVz1jHpAoNUH6AH6aI5rZ74Yg0Y6nzyU6aqpiSuNJIqV/0jzzpefBThj8+pVfIg6eyFODarfuICe57LPOyI+Fd88Y3fzWGt4X6/HhY7xDV+4HmGUJi4BtU7CH9LO5vdJxID9m384OvDA3Rg4xdM3JUx7oh1sYq8eYsd/+Cj4dVSBHSzz5kCSisEakK7FjvQJLFpjQDoOVUB6e6LsP3h4xB+E/AWZj19NNcfa4+IJgnkkLYlalXhzfp3bw8jV0WHiYdDRy271p+zbjwwRv+WGWqKo/TmZWRYzUNp7rvYcOZSqZn7zStsuEeysGxBpsgpAwH8yoxHzbfW+DpPcI=~3618358~3162673; bby_rdp=l; bby_cbc_lb=p-browse-w"
    ]

    {@bestbuy_url, headers, "add to cart"}
  end

  def smiths() do
    headers = [
      "user-agent": "vscode-restclient",
      accept: "text/html",
      "accept-encoding": "gzip, deflate",
      cookie:
        "origin=fldc; __VCAP_ID__=705f02da-456f-4101-4ceb-ac04; abTest=tl_dyn-pos_A|mrrobot_391711_A|mrrobot_ba2c7b_A; x-active-modality={\"type\":\"IN_STORE\",\"locationId\":\"70600119\"}; sid=0ce2de92-6312-77fa-aa70-2660d8c16797; _abck=089F2E2E681E71E70096ED2E756A2036~-1~YAAQzPs/F6NQQdV6AQAAAOzE1QY8+YX6RPc9NeG3sW58N9PZVI3rB2rBs57QMIjviNvcHrHsSxSux2LujxdYi3YS7zVbKAx1HLHjTTSyLsoQS3bKBEIldwXxeEtzy3pvRaZVnhAB1w1BmrKQamxzmbs/Fbj9+drQzfc5W+Z1CWvPL/fki+twEeAND545a5Qx4Kkyt5jr9PxvfS3ZzkPLxIPKNIFr3+tOqhojM00wEYXJjaJuLpH6Ur38Z4AJ9o4033MTJYrhm4Iuk52XmGNTe4NXM4vCNBLHR8yUApNsfGPMvHHCd5agDSvKwfB+nAQr2skt2Dd318sQ5kdD15zJNPzht2cD5XqAUVgLT45h0p0u79Yq2MdyADwvL50EjmbqsoBcZ75w69UchxnhTcsGAOi90eN31KCWaK8VGeVtOwPKU72xaSzp3CIokBKbphml7RbXQgwZV074YIQMgGpmVsHgQlrPv1uACibCqvv9~-1~-1~1627071602; pid=b0e378f8-eb22-4c1c-851c-2916218337ee; dtCookie=34$AE3D4791F6DD49979B16759CC1CDAED9|81222ad3b2deb1ef|1; akaalb_KT_Digital_BannerSites=~op=KT_Digital_BannerSites_KCVG_CDC_FailoverHDC:cdc|~rv=70~m=cdc:0|~os=49d9e32c4b6129ccff2e66f9d0390271~id=59e7632bfa9b06a2d8cccc590eccab73; AKA_A2=A; ak_bmsc=189FAA3A0B5844ACCD48B5779BF27B82~000000000000000000000000000000~YAAQzPs/F6RQQdV6AQAAAOzE1QwrMsm5mBvPW2ihP0nRg4UN1Z1h58xTliT+UrHmZBK00LtBJzplRjRPn/1oYgns0r8veL8/M/wsn3RXummaKMjLQF6HBJdxqjVTJ5P2ssDZOCTMw2J51E5nvT2rMxS9gIe1W5cmS+th8/N1Wu7Pu/qlvSwjuZErasPHl6al4mtObTjBZc5A38xyOh17QYGqriPcjNFCCAx7LWkgtYPXVcRiwo7GCUGu3X6v12EcmOOBYvsNuUdCyvuFzrcil/RXD3sg6zLoehAQDP7+ycWBDTEYpWXZn5s/SRKSZXtFTXp3Ih8Juq7q1pfP11Lvj0Fwk9fkFRQJJremiGojwNpzFvuaiAlA++Qv7LUYDY7oKYXh5qb/; bm_sz=9B62A548AF05B418AC702F0C25560F9E~YAAQzPs/F6VQQdV6AQAAAOzE1QyZ6CIdCbnjLRH7GWhtCPZCjZXcVXZVasi/py/4uSi6pHglfmhfUqGCcTADINRftq6tiOnxOHjC6xtctjo5cgbV3c/tCQTmhb8p3btzbCgiOuwFMvLkeNI+V2Ei/mJtRo9/TYaYAYIWWN7Lvccy1+S4oOSF3W+Mt5OFG0rRjbuE3OOOK1o6JcowwUZ3QtTr9ildr1tX8TfA06iFsYyoWHMyHGvL5n6j3mlJqaALR6hL2ukuqpx/jE1Ym0iFEpHh6nC1rr5GP5anmLsdBWgaGnOuNjn/dfN53yqnnAsxMm5dtuQZ2xHXdMzNyZOOeeUUpHgNkyYVffrZpHpAqgCPf2Fadlm55W4qpVOC9R2lVB/KwXiQ148kGJKs4iA=~4539458~4604472"
    ]

    {@smiths_url, headers, "499"}
  end
end
