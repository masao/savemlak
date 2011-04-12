TEXT = check_yomi_all.txt
NOGEOCODE = nogeocode.txt

all: geocode check_yomi_all

geocode:
	echo "自動で「緯度経度」項目が入手できなかった施設一覧です:" > $(NOGEOCODE)
	./geocode.py -transcludes:施設 -always >> $(NOGEOCODE)
	./put.py -page:利用者:Masao/NoGeocode -file:$(NOGEOCODE) -summary:「緯度経度」自動取得による更新を反映


check_yomi:
	./check_yomi.py -always -cat:文書館 -cat:博物館 -cat:図書館

check_yomi_all: check_yomi
	-rm -f $(TEXT)
	echo -e "「よみ」項目が付与されていない記事です：\n== 北海道 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:北海道 >> $(TEXT)
	echo "== 青森県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:青森県 >> $(TEXT)
	echo "== 岩手県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:岩手県 >> $(TEXT)
	echo "== 宮城県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:宮城県 >> $(TEXT)
	echo "== 秋田県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:秋田県 >> $(TEXT)
	echo "== 山形県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:山形県 >> $(TEXT)
	echo "== 福島県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:福島県 >> $(TEXT)
	echo "== 茨城県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:茨城県 >> $(TEXT)
	echo "== 栃木県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:栃木県 >> $(TEXT)
	echo "== 群馬県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:群馬県 >> $(TEXT)
	echo "== 埼玉県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:埼玉県 >> $(TEXT)
	echo "== 千葉県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:千葉県 >> $(TEXT)
	echo "== 東京都 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:東京都 >> $(TEXT)
	echo "== 神奈川県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:神奈川県 >> $(TEXT)
	echo "== 新潟県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:新潟県 >> $(TEXT)
	echo "== 山梨県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:山梨県 >> $(TEXT)
	echo "== 長野県 ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:長野県 >> $(TEXT)
	./put.py -page:利用者:Masao/Yomi_Check -file:$(TEXT) -summary:「よみ」未付与の項目一覧を更新


.PHONY: check_yomi check_yomi_all geocode
