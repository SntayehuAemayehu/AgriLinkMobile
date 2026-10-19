from rest_framework import serializers
from .models import Order, Rating


class OrderSerializer(serializers.ModelSerializer):
    product_title = serializers.CharField(source='product.title', read_only=True)
    product_image = serializers.SerializerMethodField()
    buyer_name = serializers.CharField(source='buyer.username', read_only=True)
    buyer_phone = serializers.CharField(source='buyer.phone', read_only=True)
    farmer_name = serializers.CharField(source='product.farmer.username', read_only=True)
    farmer_phone = serializers.CharField(source='product.farmer.phone', read_only=True)
    farmer_id = serializers.IntegerField(source='product.farmer.id', read_only=True)

    class Meta:
        model = Order
        fields = '__all__'
        read_only_fields = ['buyer', 'total_price', 'commission', 'status']

    def get_product_image(self, obj):
        if obj.product.image:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.product.image.url)
        return None


class RatingSerializer(serializers.ModelSerializer):
    rater_name = serializers.CharField(source='rater.username', read_only=True)
    ratee_name = serializers.CharField(source='ratee.username', read_only=True)

    class Meta:
        model = Rating
        fields = '__all__'
        read_only_fields = ['rater']