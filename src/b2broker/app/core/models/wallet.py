from app.core.models.base import DecimalCustom, Timestamped
from django.db import models


class Wallet(Timestamped):

    label = models.CharField(
        max_length=255,
        null=False,
        blank=False,
        help_text="Label for Wallet",
    )

    balance = DecimalCustom(
        decimal_places=18,
        default=0,
        help_text="Up to date balance amount with 18 precision points",
    )

    def save(self, *args, **kwargs):
        super().full_clean()
        return super().save(*args, **kwargs)

    class Meta:
        # add unsigned in DB level
        constraints = [
            models.CheckConstraint(
                check=models.Q(balance__gte=0),
                name="balance_non_negative",
            )
        ]
