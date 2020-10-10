import Vapor
import Fluent
import Stripe

struct StripeController:RouteCollection {

    struct ChargeToken: Content {
        var token: String
    }

    struct Link:Content {
        let url:String?
    }

    func boot(routes: RoutesBuilder) throws {
        routes.post("chargeCustomer", use: chargeCustomer)
        routes.post("payout", use: payout)
        routes.post("accountLink", use: accountLink)
    }

    func chargeCustomer(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let charge = try req.content.decode(ChargeToken.self)
        return req.stripe.charges.create(amount: 2500, currency: .usd, source: charge.token).map { stripeCharge in
            if stripeCharge.status == .succeeded {
                return .ok
            } else {
                print("Stripe charge status: \(String(describing:stripeCharge.status?.rawValue))")
                return .badRequest
            }
        }
    }

    func payout(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let payout = try req.content.decode(StripePayout.self)

        guard let amount = payout.amount else {
            throw Abort(.badRequest)
        }

        guard let currency = payout.currency else {
            throw Abort(.badRequest)
        }

        guard let method = payout.method else {
            throw Abort(.badRequest)
        }

        return req.stripe.payouts.create(amount: amount, currency: currency, method: method).map { payout in
            if payout.status == .paid {
                return .ok
            } else if payout.status == .failed {
                print("Stripe payout status: \(String(describing:payout.status?.rawValue))")
                return .badRequest
            }else {
                print("Stripe payout status: \(String(describing:payout.status?.rawValue))")
                return .ok
            }
        }
    }

    func accountLink(_ req: Request) throws -> EventLoopFuture<Link> {
        return req.stripe.accountLinks.create(account: "String", refreshUrl: "String", returnUrl: "String", type: .accountOnboarding,collect:nil).map { link in

            let url = Link(url:link.url)

            return url
        }
    }
}