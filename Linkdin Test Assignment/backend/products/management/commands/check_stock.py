# products/management/commands/check_stock.py

from django.core.management.base import BaseCommand
from products.models import Product

class Command(BaseCommand):
    help = 'Check and display stock status of all products'

    def handle(self, *args, **options):
        products = Product.objects.all()
        
        out_of_stock = products.filter(stock=0)
        low_stock = products.filter(stock__gt=0, stock__lte=5)
        in_stock = products.filter(stock__gt=5)
        
        self.stdout.write(self.style.SUCCESS(f'\n📊 STOCK REPORT'))
        self.stdout.write(self.style.SUCCESS(f'=' * 50))
        self.stdout.write(f'Total Products: {products.count()}')
        self.stdout.write(f'In Stock (>5): {in_stock.count()}')
        self.stdout.write(f'Low Stock (1-5): {low_stock.count()}')
        self.stdout.write(self.style.WARNING(f'Out of Stock (0): {out_of_stock.count()}'))
        
        if out_of_stock.exists():
            self.stdout.write(self.style.ERROR('\n❌ OUT OF STOCK:'))
            for p in out_of_stock:
                self.stdout.write(f'  - {p.name}')
        
        if low_stock.exists():
            self.stdout.write(self.style.WARNING('\n⚠️  LOW STOCK:'))
            for p in low_stock:
                self.stdout.write(f'  - {p.name}: {p.stock} left')