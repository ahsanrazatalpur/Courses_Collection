from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from .models import Cart, CartItem
from .serializers import CartSerializer
from products.models import Product

class CartView(APIView):
    permission_classes = [IsAuthenticated]

    def get_cart(self, user):
        cart, _ = Cart.objects.get_or_create(user=user)
        return cart

    # GET /api/cart/
    def get(self, request):
        cart = self.get_cart(request.user)
        serializer = CartSerializer(cart)
        return Response(serializer.data)

class AddItemView(APIView):
    permission_classes = [IsAuthenticated]

    # POST /api/cart/add_item/
    def post(self, request):
        product_id = request.data.get("product_id")
        quantity = int(request.data.get("quantity", 1))

        try:
            product = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response({"error": "Product not found"}, status=status.HTTP_404_NOT_FOUND)

        cart = Cart.objects.get_or_create(user=request.user)[0]
        cart_item, created = CartItem.objects.get_or_create(cart=cart, product=product)
        if not created:
            cart_item.quantity += quantity
        else:
            cart_item.quantity = quantity
        cart_item.save()

        serializer = CartSerializer(cart)
        return Response(serializer.data, status=status.HTTP_200_OK)

class UpdateItemView(APIView):
    permission_classes = [IsAuthenticated]

    # PATCH /api/cart/update_item/
    def patch(self, request):
        product_id = request.data.get("product_id")
        quantity = int(request.data.get("quantity", 1))

        cart = Cart.objects.get_or_create(user=request.user)[0]

        try:
            cart_item = CartItem.objects.get(cart=cart, product_id=product_id)
        except CartItem.DoesNotExist:
            return Response({"error": "Item not found"}, status=status.HTTP_404_NOT_FOUND)

        if quantity <= 0:
            cart_item.delete()
        else:
            cart_item.quantity = quantity
            cart_item.save()

        serializer = CartSerializer(cart)
        return Response(serializer.data, status=status.HTTP_200_OK)

class RemoveItemView(APIView):
    permission_classes = [IsAuthenticated]

    # DELETE /api/cart/remove_item/
    def delete(self, request):
        product_id = request.data.get("product_id")
        cart = Cart.objects.get_or_create(user=request.user)[0]

        try:
            CartItem.objects.get(cart=cart, product_id=product_id).delete()
        except CartItem.DoesNotExist:
            return Response({"error": "Item not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = CartSerializer(cart)
        return Response(serializer.data, status=status.HTTP_200_OK)
